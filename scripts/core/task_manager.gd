extends Node

# Central owner of every task in the game.
#
# Two flows feed it:
#   acquire - a customer NPC offers a task, the player accepts -> add_task() -> backlog
#   assign  - the player picks a backlog task for a worker NPC -> assign() -> active
#
# A task can be worked by several workers at once. Every on-shift worker on a
# task burns one tick of its remaining time per tick, so two workers finish it
# twice as fast. Assigning to an already active task joins that task instead of
# starting a second copy of it.
#
# Progress is driven by TimeManager.tick. Nothing else should count a task down.
#
# Tasks are held against Worker resources, not against the NPC nodes that draw
# them: nodes die with their scene, the payroll in WorkerManager does not, so an
# assignment survives a scene change.
#
# Task.time and Task.deadline are authored in in-game HOURS and converted to ticks here.

signal backlog_changed
signal task_assigned(task: Task, worker: WorkerData)
signal task_unassigned(task: Task, worker: WorkerData)
signal task_progressed(task: Task, worker: WorkerData, remaining: int)
signal task_finished(task: Task, worker: WorkerData)
signal task_failed(task: Task)

# Accepted from a customer, waiting for a worker
var backlog: Array[Task] = []

# Task -> { "workers": [Worker], "remaining": int, "total": int }
var active: Dictionary = {}

var completed: Array[Task] = []

# Task -> ticks left before the task expires. Counts down in backlog and while active.
var _deadlines: Dictionary = {}

func _ready() -> void:
	# Deferred so this does not depend on autoload registration order
	_connect_clock.call_deferred()

func _connect_clock() -> void:
	TimeManager.tick.connect(_on_tick)

# ==== ACQUIRE ====

func add_task(task: Task) -> bool:
	if task == null:
		return false
	if backlog.has(task) or active.has(task):
		push_warning("Task already taken: %s" % task.title)
		return false
	backlog.append(task)
	_deadlines[task] = TimeManager.hours_to_ticks(task.deadline)
	backlog_changed.emit()
	return true

# ==== ASSIGN ====

func can_assign(task: Task, worker: WorkerData) -> bool:
	if task == null or worker == null:
		return false
	if is_busy(worker):
		return false
	return backlog.has(task) or active.has(task)

func assign(task: Task, worker: WorkerData) -> bool:
	if not can_assign(task, worker):
		return false

	if active.has(task):
		# Joining a task already in progress: keep its remaining time as is.
		active[task]["workers"].append(worker)
		task_assigned.emit(task, worker)
		task_progressed.emit(task, worker, active[task]["remaining"])
		return true

	assert(task.time > 0, "Task time must not be zero")
	var ticks := TimeManager.hours_to_ticks(task.time)
	backlog.erase(task)
	active[task] = {"workers": [worker], "remaining": ticks, "total": ticks}
	backlog_changed.emit()
	task_assigned.emit(task, worker)
	task_progressed.emit(task, worker, ticks)
	return true

# Pulls one worker off a task. The task keeps running if others remain on it,
# and goes back to the backlog once the last one leaves.
func unassign(worker: WorkerData) -> bool:
	var task := task_of(worker)
	if task == null:
		return false
	active[task]["workers"].erase(worker)
	task_unassigned.emit(task, worker)
	if active[task]["workers"].is_empty():
		abandon(task)
	return true

# Drops every worker and sends the task back to the backlog.
func abandon(task: Task) -> bool:
	if not active.has(task):
		return false
	var workers := workers_of(task)
	active.erase(task)
	backlog.append(task)
	for worker in workers:
		task_unassigned.emit(task, worker)
	backlog_changed.emit()
	return true

func is_busy(worker: WorkerData) -> bool:
	return task_of(worker) != null

func task_of(worker: WorkerData) -> Task:
	for task in active:
		if active[task]["workers"].has(worker):
			return task
	return null

func remaining_for(worker: WorkerData) -> int:
	var task := task_of(worker)
	if task == null:
		return -1
	return active[task]["remaining"]

# ==== QUERIES (read-only views, used by the task board) ====

# Every worker on the task, empty while it sits in the backlog.
func workers_of(task: Task) -> Array[WorkerData]:
	var out: Array[WorkerData] = []
	if active.has(task):
		out.assign(active[task]["workers"])
	return out

# First worker on the task, for callers that only need one name.
func worker_of(task: Task) -> WorkerData:
	var workers := workers_of(task)
	return workers[0] if not workers.is_empty() else null

# 0.0 in the backlog, 1.0 once completed, in between while active.
func progress_of(task: Task) -> float:
	if completed.has(task):
		return 1.0
	if not active.has(task):
		return 0.0
	var entry = active[task]
	var total: int = entry["total"]
	if total <= 0:
		return 0.0
	return clampf(1.0 - float(entry["remaining"]) / float(total), 0.0, 1.0)

# Ticks left before the task expires, -1 if it no longer has a deadline.
func deadline_for(task: Task) -> int:
	return _deadlines.get(task, -1)

# ==== PRIVATE ====

func _on_tick(_current_tick: int) -> void:
	_tick_active()
	_tick_deadlines()

func _tick_active() -> void:
	for task in active.keys():
		var entry = active[task]
		var working: Array[WorkerData] = []
		for worker in entry["workers"]:
			if WorkerManager.is_in_shift(worker):
				working.append(worker)
		if working.is_empty():
			continue
		# Each on-shift worker burns one tick of the task per tick.
		entry["remaining"] -= working.size()
		if entry["remaining"] > 0:
			for worker in working:
				task_progressed.emit(task, worker, entry["remaining"])
		else:
			active.erase(task)
			_deadlines.erase(task)
			completed.append(task)
			GameManager.finish_task(task)
			for worker in entry["workers"]:
				task_finished.emit(task, worker)

func _tick_deadlines() -> void:
	# Only unfinished tasks are still in _deadlines
	for task in _deadlines.keys():
		_deadlines[task] -= 1
		if _deadlines[task] > 0:
			continue
		_deadlines.erase(task)
		if backlog.has(task):
			backlog.erase(task)
			backlog_changed.emit()
		else:
			active.erase(task)
		task_failed.emit(task)

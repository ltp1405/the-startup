extends Node

# Central owner of every task in the game.
#
# Two flows feed it:
#   acquire - a customer NPC offers a task, the player accepts -> add_task() -> backlog
#   assign  - the player picks a backlog task for a worker NPC -> assign() -> active
#
# Progress is driven by TimeManager.tick. Nothing else should count a task down.
#
# Task.time and Task.deadline are authored in in-game HOURS and converted to ticks here.

signal backlog_changed
signal task_assigned(task: Task, worker: Object)
signal task_progressed(task: Task, worker: Object, remaining: int)
signal task_finished(task: Task, worker: Object)
signal task_failed(task: Task)

# Accepted from a customer, waiting for a worker
var backlog: Array[Task] = []

# Task -> { "worker": Object, "remaining": int }
var active: Dictionary = {}

var completed: Array[Task] = []

# Task -> ticks left before the task expires. Counts down in backlog and while active.
var _deadlines: Dictionary = {}

func _ready() -> void:
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

func can_assign(task: Task, worker: Object) -> bool:
	return task != null and worker != null and backlog.has(task) and not is_busy(worker)

func assign(task: Task, worker: Object) -> bool:
	if not can_assign(task, worker):
		return false
	assert(task.time > 0, "Task time must not be zero")
	var ticks := TimeManager.hours_to_ticks(task.time)
	backlog.erase(task)
	active[task] = {"worker": worker, "remaining": ticks}
	backlog_changed.emit()
	task_assigned.emit(task, worker)
	task_progressed.emit(task, worker, ticks)
	return true

func abandon(task: Task) -> bool:
	if not active.has(task):
		return false
	active.erase(task)
	backlog.append(task)
	backlog_changed.emit()
	return true

func is_busy(worker: Object) -> bool:
	for entry in active.values():
		if entry["worker"] == worker:
			return true
	return false

func task_of(worker: Object) -> Task:
	for task in active:
		if active[task]["worker"] == worker:
			return task
	return null

func remaining_for(worker: Object) -> int:
	for task in active:
		if active[task]["worker"] == worker:
			return active[task]["remaining"]
	return -1

# ==== PRIVATE ====

func _on_tick(_current_tick: int) -> void:
	_tick_active()
	_tick_deadlines()

func _tick_active() -> void:
	for task in active.keys():
		var entry = active[task]
		var worker = entry["worker"]
		entry["remaining"] -= 1
		if entry["remaining"] > 0:
			task_progressed.emit(task, worker, entry["remaining"])
		else:
			active.erase(task)
			_deadlines.erase(task)
			completed.append(task)
			GameManager.finish_task(task)
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

class_name TaskBoardRow
extends PanelContainer

# One line on the task board. Read-only: it never mutates task state.
#
# setup() fills everything and is safe to call before the node is in the tree.
# refresh_live() updates only the parts that move with the clock, so the board
# can tick without rebuilding its rows.

enum State { ACTIVE, OFF_SHIFT, BACKLOG, DONE }

const COLORS := {
	State.ACTIVE: Color(0.45, 0.85, 0.45),
	State.OFF_SHIFT: Color(0.85, 0.7, 0.3),
	State.BACKLOG: Color(0.75, 0.75, 0.75),
	State.DONE: Color(0.5, 0.7, 0.95),
}

const LABELS := {
	State.ACTIVE: "● ACTIVE",
	State.OFF_SHIFT: "⏸ OFF SHIFT",
	State.BACKLOG: "○ BACKLOG",
	State.DONE: "✓ DONE",
}

# Deadline text goes red below this many in-game hours
const URGENT_HOURS := 2.0

@onready var state_label: Label = $HBoxContainer/State
@onready var title_label: Label = $HBoxContainer/Title
@onready var bar: ProgressBar = $HBoxContainer/Bar
@onready var workers_label: Label = $HBoxContainer/Workers
@onready var detail_label: Label = $HBoxContainer/Detail

var task: Task
var state := State.BACKLOG

func setup(p_task: Task, p_state: State) -> void:
	task = p_task
	state = p_state
	if is_node_ready():
		_refresh()

func _ready() -> void:
	_refresh()

# Only the clock-driven parts. Called every tick while the board is open.
func refresh_live() -> void:
	if task == null or not is_node_ready():
		return
	bar.value = TaskManager.progress_of(task) * 100.0
	# Crew is live too: workers join, leave and go off shift without the row
	# changing bucket, so this cannot live in _refresh().
	workers_label.text = _workers_text()
	workers_label.add_theme_color_override("font_color", _workers_color())
	detail_label.text = _detail_text()
	detail_label.add_theme_color_override("font_color", _detail_color())

# ==== PRIVATE ====

func _refresh() -> void:
	if task == null:
		return
	state_label.text = LABELS[state]
	state_label.add_theme_color_override("font_color", COLORS[state])
	title_label.text = task.title
	bar.visible = state == State.ACTIVE or state == State.OFF_SHIFT
	refresh_live()

# Assigned crew, off-shift ones marked. "-" while nobody is on the task.
func _workers_text() -> String:
	var parts := []
	for worker in _workers():
		var display: String = worker.name if not worker.name.is_empty() else "?"
		if not WorkerManager.is_in_shift(worker):
			display += " ⏸"
		parts.append(display)
	if parts.is_empty():
		return "-"
	return ", ".join(parts)

func _workers_color() -> Color:
	var crew := _workers()
	if crew.is_empty():
		return Color(0.6, 0.6, 0.6)
	for worker in crew:
		if not WorkerManager.is_in_shift(worker):
			return COLORS[State.OFF_SHIFT]
	return COLORS[State.ACTIVE]

func _detail_text() -> String:
	match state:
		State.ACTIVE:
			return "%.1fh left" % _hours_left()
		State.OFF_SHIFT:
			return "resumes %d:00" % _shift_start()
		State.BACKLOG:
			var ticks := TaskManager.deadline_for(task)
			if ticks < 0:
				return "no deadline"
			return "due %.1fh" % TimeManager.ticks_to_hours(ticks)
		State.DONE:
			return "+$%d" % task.money
	return ""

func _detail_color() -> Color:
	if state == State.BACKLOG:
		var ticks := TaskManager.deadline_for(task)
		if ticks >= 0 and TimeManager.ticks_to_hours(ticks) < URGENT_HOURS:
			return Color(0.95, 0.35, 0.35)
	if state == State.OFF_SHIFT:
		return COLORS[State.OFF_SHIFT]
	return Color(0.88, 0.88, 0.88)

func _hours_left() -> float:
	var worker := TaskManager.worker_of(task)
	if worker == null:
		return 0.0
	return TimeManager.ticks_to_hours(TaskManager.remaining_for(worker))

# Earliest shift start among the crew - when work resumes on this task.
func _shift_start() -> int:
	var soonest := -1
	for worker in _workers():
		if soonest < 0 or worker.shift_start < soonest:
			soonest = worker.shift_start
	return maxi(soonest, 0)

func _workers() -> Array[WorkerData]:
	return TaskManager.workers_of(task)

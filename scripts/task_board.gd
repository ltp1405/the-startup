extends CenterContainer

# Read-only board listing every task the studio knows about.
#
# Opened from anywhere with the "task_board" action. It only reads TaskManager -
# nothing here assigns, abandons or completes a task.
#
# Rows are rebuilt when a task changes bucket, and merely refreshed on each tick,
# so an open board does not churn the scene tree every 5 seconds.

const ROW := preload("res://ui/task_board_row.tscn")
const State := TaskBoardRow.State

@onready var summary: Label = $PanelContainer/MarginContainer/VBoxContainer/Summary
@onready var row_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Scroll/RowList

var _empty_label: Label

func _ready() -> void:
	add_to_group("task_board")
	UIManager.register(self)
	_empty_label = Label.new()
	_empty_label.text = "Chưa có task nào"
	row_list.add_child(_empty_label)

	TaskManager.backlog_changed.connect(_rebuild)
	TaskManager.task_assigned.connect(_on_task_changed)
	TaskManager.task_unassigned.connect(_on_task_changed)
	TaskManager.task_finished.connect(_on_task_changed)
	TaskManager.task_failed.connect(_on_task_failed)
	TimeManager.tick.connect(_on_tick)
	_rebuild()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("task_board"):
		toggle()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	_rebuild()
	visible = true

func close() -> void:
	visible = false

# ==== PRIVATE ====

# Every task, grouped and ordered the way the board reads top to bottom.
func _rows() -> Array:
	var active_rows := []
	var off_shift_rows := []
	for task in TaskManager.active:
		if _any_on_shift(task):
			active_rows.append(task)
		else:
			off_shift_rows.append(task)

	var backlog := TaskManager.backlog.duplicate()
	backlog.sort_custom(func(a, b): return TaskManager.deadline_for(a) < TaskManager.deadline_for(b))

	var done := TaskManager.completed.duplicate()
	done.reverse()

	var rows := []
	for task in active_rows:
		rows.append([task, State.ACTIVE])
	for task in off_shift_rows:
		rows.append([task, State.OFF_SHIFT])
	for task in backlog:
		rows.append([task, State.BACKLOG])
	for task in done:
		rows.append([task, State.DONE])
	return rows

# A task counts as active while at least one of its workers is on shift.
func _any_on_shift(task: Task) -> bool:
	for worker in TaskManager.workers_of(task):
		if WorkerManager.is_in_shift(worker):
			return true
	return false

func _rebuild() -> void:
	for child in row_list.get_children():
		if child == _empty_label:
			continue
		# Detached first: queue_free() only frees at the end of the frame, and a
		# rebuild can run several times before then (add_task, assign, ...).
		row_list.remove_child(child)
		child.queue_free()

	var rows := _rows()
	for row in rows:
		var line = ROW.instantiate()
		line.setup(row[0], row[1])
		row_list.add_child(line)

	_empty_label.visible = rows.is_empty()
	_refresh_summary()

func _refresh_summary() -> void:
	summary.text = "%d active · %d queued · %d done · %d workers assigned" % [
		TaskManager.active.size(),
		TaskManager.backlog.size(),
		TaskManager.completed.size(),
		_assigned_count(),
	]

func _assigned_count() -> int:
	var total := 0
	for task in TaskManager.active:
		total += TaskManager.workers_of(task).size()
	return total

func _on_tick(_total_tick: int) -> void:
	if not visible:
		return
	# A worker going on or off shift changes which bucket a row belongs to,
	# so the grouping has to be re-checked, not just the labels.
	if _grouping_changed():
		_rebuild()
		return
	for child in row_list.get_children():
		if child.has_method("refresh_live"):
			child.refresh_live()

func _grouping_changed() -> bool:
	var rows := _rows()
	var lines := row_list.get_children().filter(func(c): return c != _empty_label)
	if lines.size() != rows.size():
		return true
	for i in rows.size():
		if lines[i].task != rows[i][0] or lines[i].state != rows[i][1]:
			return true
	return false

func _on_task_changed(_task: Task, _worker: WorkerData) -> void:
	_rebuild()

func _on_task_failed(_task: Task) -> void:
	_rebuild()

func _on_close_btn_pressed() -> void:
	close()

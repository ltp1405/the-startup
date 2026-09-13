extends CenterContainer

const TASK_LINE = preload("res://ui/task_line.tscn")

@onready var item_list = $PaneContainer/VBoxContainer/Scroll/ItemList

# Worker the player is currently assigning a task to
var worker: Object = null

var _empty_label: Label

func _ready() -> void:
	add_to_group("choose_task_ui")
	_empty_label = Label.new()
	_empty_label.text = "Chưa có task nào"
	item_list.add_child(_empty_label)
	TaskManager.backlog_changed.connect(_refresh)
	_refresh()

# Opens the picker for a given worker NPC.
func open_for(p_worker: Object) -> void:
	worker = p_worker
	_refresh()
	visible = true

func _refresh() -> void:
	for child in item_list.get_children():
		if child != _empty_label:
			child.queue_free()
	for task in TaskManager.backlog:
		var line = TASK_LINE.instantiate()
		line.setup(task)
		line.task_accepted.connect(_on_task_accepted)
		item_list.add_child(line)
	_empty_label.visible = TaskManager.backlog.is_empty()

func _on_task_accepted(task: Task) -> void:
	if worker == null:
		push_warning("No worker selected for task assignment")
		return
	if not TaskManager.assign(task, worker):
		push_warning("Cannot assign '%s' to %s" % [task.title, worker])
		return
	worker = null
	visible = false

func _on_close_btn_pressed() -> void:
	worker = null
	visible = false

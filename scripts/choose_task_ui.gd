extends CenterContainer

const TASK_LINE = preload("res://ui/task_line.tscn")

@onready var item_list = $PaneContainer/VBoxContainer/Scroll/ItemList

# NPC the player is currently assigning a task to, and its Worker
var npc: Object = null
var worker: WorkerData = null

var _empty_label: Label

func _ready() -> void:
	add_to_group("choose_task_ui")
	UIManager.register(self)
	_empty_label = Label.new()
	_empty_label.text = "No task"
	item_list.add_child(_empty_label)
	TaskManager.backlog_changed.connect(_refresh)
	TaskManager.task_assigned.connect(_on_roster_changed)
	TaskManager.task_unassigned.connect(_on_roster_changed)
	_refresh()

# Opens the picker for a given worker NPC.
func open_for(p_npc: Object) -> void:
	npc = p_npc
	worker = p_npc.get_worker() if p_npc != null and p_npc.has_method("get_worker") else null
	_refresh()
	visible = true

func _refresh() -> void:
	for child in item_list.get_children():
		if child != _empty_label:
			child.queue_free()
	var count := 0
	for task in TaskManager.backlog:
		_add_line(task, 0)
		count += 1
	# Tasks already in progress: a worker can join them to finish them faster.
	for task in TaskManager.active:
		var crew: Array = TaskManager.workers_of(task)
		if crew.has(worker):
			continue
		_add_line(task, crew.size())
		count += 1
	_empty_label.visible = count == 0

func _add_line(task: Task, crew: int) -> void:
	var line = TASK_LINE.instantiate()
	line.setup(task, crew)
	line.task_accepted.connect(_on_task_accepted)
	item_list.add_child(line)

func _on_roster_changed(_task: Task, _worker: WorkerData) -> void:
	_refresh()

func _on_task_accepted(task: Task) -> void:
	if worker == null:
		push_warning("No worker selected for task assignment")
		return
	if not TaskManager.assign(task, worker):
		push_warning("Cannot assign '%s' to %s" % [task.title, worker.name])
		return
	npc = null
	worker = null
	visible = false

func _on_close_btn_pressed() -> void:
	npc = null
	worker = null
	visible = false

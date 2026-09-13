extends Container

signal accept(task: Task)

@onready var title = $MarginContainer/PanelContainer/VBoxContainer/Title
@onready var description = $MarginContainer/PanelContainer/VBoxContainer/Description

var current_task: Task = null

# NPC that offered the task, notified when the player accepts
var giver: Object = null

func _ready() -> void:
	add_to_group("accept_task_box")
	_refresh()

# Shows the offer. Safe to call before the node is in the tree.
func offer(task: Task, p_giver: Object = null) -> void:
	current_task = task
	giver = p_giver
	if is_node_ready():
		_refresh()
	visible = true

# Kept for callers that only have a task
func setup(task: Task) -> void:
	offer(task)

func _refresh() -> void:
	if current_task == null:
		return
	title.text = current_task.title
	description.text = current_task.description

func _on_accept_pressed() -> void:
	assert(current_task != null, "Must assign task before showing accept task box")
	if TaskManager.add_task(current_task):
		if giver and giver.has_method("on_task_offer_accepted"):
			giver.on_task_offer_accepted(current_task)
		accept.emit(current_task)
	_close()

func _on_close_pressed() -> void:
	_close()

func _close() -> void:
	current_task = null
	giver = null
	visible = false

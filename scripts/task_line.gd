extends Control

@onready var description = $HBoxContainer/VBoxContainer/Description
@onready var title = $HBoxContainer/VBoxContainer/Title
@onready var avatar = $"HBoxContainer/Customer Avatar"
@onready var est = $HBoxContainer/VBoxContainer/HBoxContainer/Est
@onready var deadline = $HBoxContainer/VBoxContainer/HBoxContainer/Deadline
@onready var money = $HBoxContainer/VBoxContainer/HBoxContainer/Money

signal task_accepted(task: Task)

var task: Task

# How many workers are already on this task, 0 while it is in the backlog.
var crew := 0

# Fills the row. Safe to call before the node is in the tree.
func setup(p_task: Task, p_crew := 0) -> void:
	task = p_task
	crew = p_crew
	if is_node_ready():
		_refresh()

func _ready() -> void:
	_refresh()

func _refresh() -> void:
	if task == null:
		return
	description.text = task.description
	title.text = task.title
	avatar.texture = task.customer.avatar if task.customer else null
	est.text = "%dhrs · %d working" % [task.time, crew] if crew > 0 else "%dhrs" % task.time
	deadline.text = "%dhrs" % task.deadline
	money.text = "$%d" % task.money

func _on_accept_btn_pressed() -> void:
	if task != null:
		task_accepted.emit(task)

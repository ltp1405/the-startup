extends Control

@export var task: Task

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if task != null:
		$Description.text = task.description
		$Title.text = task.title
		$"Customer Avatar".texture = task.customer.avatar

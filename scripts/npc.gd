extends CharacterBody2D

@export var walk_speed := 55.0
@export var run_speed := 110.0

# true  = worker, the player assigns backlog tasks to them
# false = customer, they hand out the tasks in tasks_to_give
@export var can_assign_task := true
@export var tasks_to_give: Array[Task]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

var facing := "down"

func _ready() -> void:
	TaskManager.task_assigned.connect(_on_task_assigned)
	TaskManager.task_progressed.connect(_on_task_progressed)
	TaskManager.task_finished.connect(_on_task_finished)
	TaskManager.task_failed.connect(_on_task_failed)

func play(action: String) -> void:
	var anim := "%s_%s" % [action, facing]
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

func interact() -> void:
	if can_assign_task:
		if TaskManager.is_busy(self):
			return
		var ui = get_tree().get_first_node_in_group("choose_task_ui")
		if ui:
			ui.open_for(self)
	elif tasks_to_give.size() > 0:
		var box = get_tree().get_first_node_in_group("accept_task_box")
		if box:
			# Peek only. The task is removed in _on_task_offer_accepted,
			# so closing the box does not lose it.
			box.offer(tasks_to_give[0], self)

# Called by AcceptTaskBox once the player accepts an offer from this NPC
func on_task_offer_accepted(task: Task) -> void:
	tasks_to_give.erase(task)

# ==== TASK DISPLAY ====

func _on_task_assigned(_task: Task, worker: Object) -> void:
	if worker == self:
		label.visible = true

func _on_task_progressed(_task: Task, worker: Object, remaining: int) -> void:
	if worker == self:
		label.text = "%d hrs remain" % remaining

func _on_task_finished(_task: Task, worker: Object) -> void:
	if worker == self:
		label.visible = false

func _on_task_failed(task: Task) -> void:
	if TaskManager.task_of(self) == task:
		label.visible = false

extends CharacterBody2D

@onready var debug_label = $Debug/DebugLabel
@export var walk_speed := 55.0
@export var run_speed := 110.0

# true  = worker, the player assigns backlog tasks to them
# false = customer, they hand out the tasks in tasks_to_give
@export var tasks_to_give: Array[Task]

@export var worker_template: WorkerData

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var work_position: Vector2
@export var speed: float = 40
@export var target_position: Node2D:
	set(_target):
		nav_agent.target_position = _target.position
		
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var facing := "down"

func set_movement_target(target_point: Vector2) -> void:
	nav_agent.target_position = target_point

func _physics_process(_delta: float) -> void:
	if nav_agent == null:
		return
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_path_position)
	var running = false
	velocity = direction * speed
	if not nav_agent.is_target_reached() and not velocity.is_zero_approx():
		if absf(velocity.x) > absf(velocity.y):
			facing = "right" if velocity.x > 0.0 else "left"
		else:
			facing = "down" if velocity.y > 0.0 else "up"
		play("run" if running else "walk")
	else:
		play("idle")
	move_and_slide()

func _ready() -> void:
	$Worker.setup(worker_template)
	_update_debug_info()

func play(action: String) -> void:
	var anim := "%s_%s" % [action, facing]
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

# One action runs straight away, several put the choice to the player first.
func interact() -> void:
	var actions := _available_interactions()
	print(actions)
	match actions.size():
		0:
			return
		1:
			do_interaction(actions[0])
		_:
			var panel = get_tree().get_first_node_in_group("select_action_panel")
			if panel:
				panel.open_for(self, actions)
			else:
				# No chooser in the scene: fall back to the first action so the
				# NPC is never completely dead to interact.
				do_interaction(actions[0])

# Runs one action id from _available_interactions(). Also the entry point the
# SelectActionPanel calls back into.
func do_interaction(action: String) -> void:
	match action:
		"assign_task":
			$Worker.assign_task()
			print("assign")
		"unassign_task":
			$Worker.unassign_task()
		"give_task":
			var box = get_tree().get_first_node_in_group("accept_task_box")
			if box:
				# Peek only. The task is removed in _on_task_offer_accepted,
				# so closing the box does not lose it.
				box.offer(tasks_to_give[0], self)
		"hire":
			$Worker.hire()
		_:
			push_warning("Unknown interaction: %s" % action)

# Called by AcceptTaskBox once the player accepts an offer from this NPC
func on_task_offer_accepted(task: Task) -> void:
	tasks_to_give.erase(task)

# Everything the player can do with this NPC right now, in menu order.
func _available_interactions() -> Array[String]:
	var result: Array[String] = []
	if $Worker.can_hire():
		result.push_back("hire")
	elif $Worker.can_assign_task():
		# A worker already on a task can be pulled off it, not piled onto another.
		if $Worker.is_busy():
			result.push_back("unassign_task")
		else:
			result.push_back("assign_task")
	if tasks_to_give.size() > 0:
		result.push_back("give_task")
	return result

func _update_debug_info():
	var debug_text = ""
	
	if tasks_to_give.size() > 0:
		debug_text += "has %d requests\n" % tasks_to_give.size()
	
	debug_label.text = debug_text


func _on_navigation_agent_2d_target_reached() -> void:
	_sit(nav_agent.target_position)
	nav_agent.target_position = Vector2.ZERO


func _on_interaction_area_interact_requested() -> void:
	interact()

func _sit(to: Vector2) -> void:
	position = to
	facing = "down"
	play("idle")
	


func _on_worker_task_started() -> void:
	set_movement_target(work_position)

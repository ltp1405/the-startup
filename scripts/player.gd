extends CharacterBody2D

@export var walk_speed := 55.0
@export var run_speed := 110.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area = $InteractionArea

var facing := "down"

func _ready() -> void:
	pass
	
func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var running := false
	velocity = input * (run_speed if running else walk_speed)
	move_and_slide()

	if input != Vector2.ZERO:
		if absf(input.x) > absf(input.y):
			facing = "right" if input.x > 0.0 else "left"
		else:
			facing = "down" if input.y > 0.0 else "up"
		play("run" if running else "walk")
	else:
		play("idle")

func _input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		var overlapping_areas = interaction_area.get_overlapping_areas()
		for area in overlapping_areas:
			if area.has_method("interact"):
				area.interact()
				break # Stops after interacting with the first valid object

func play(action: String) -> void:
	var anim := "%s_%s" % [action, facing]
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

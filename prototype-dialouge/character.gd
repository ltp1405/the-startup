extends CharacterBody2D

@export var walk_speed := 55.0
@export var run_speed := 110.0
@export var initial_facing := "down"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing

func _ready() -> void:
	facing = initial_facing
	
func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var running := Input.is_action_pressed("ui_select")
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


func play(action: String) -> void:
	var anim := "%s_%s" % [action, facing]
	if sprite.sprite_frames.has_animation(anim) and sprite.animation != anim:
		sprite.play(anim)

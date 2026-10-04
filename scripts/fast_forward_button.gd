extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.is_debug_build():
		visible = true
	else:
		visible = false

func _on_pressed() -> void:
	TimeManager.fast_forward()

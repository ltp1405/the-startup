extends CenterContainer

var close_btn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_btn = $PaneContainer/VBoxContainer/CloseBtn

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_close_btn_pressed() -> void:
	visible = false

extends Area2D

@export var next_scene: PackedScene
@export var next_scene_name = ""

func _on_body_entered(body: Node2D):
	if body.has_method("play"):
		if next_scene != null:
			get_tree().change_scene_to_packed(next_scene)
		elif next_scene_name != "":
			get_tree().change_scene_to_file("res://scenes/%s.tscn" % next_scene_name)
		else:
			push_warning("Transition triggered, but no scene path is set!")

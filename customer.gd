class_name Customer
extends Resource

@export var name: String
@export var avatar: Texture2D

func _init(p_name = "Customer", p_avatar = null) -> void:
	name = p_name
	avatar = p_avatar

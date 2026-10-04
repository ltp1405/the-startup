class_name ShopItem
extends Resource

@export var title: String
@export var icon: Texture
@export var description: String
@export var price: int

func _init(p_title = "", p_description = "", p_price = 0, p_icon = null) -> void:
	title = p_title
	description = p_description
	price = p_price
	icon = p_icon

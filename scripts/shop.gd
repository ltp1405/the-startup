extends Area2D

# A shop sells its own catalog. Two shops can share item resources - the player's
# owned count is keyed by the ShopItem, so it stays correct either way.
@export var catalog: ShopCatalog
@export var shop_name := "Shop"

func interact() -> void:
	if catalog == null:
		push_warning("Shop '%s' has no catalog assigned" % shop_name)
		return
	var ui = get_tree().get_first_node_in_group("shop_ui")
	if ui:
		ui.open(catalog, shop_name)

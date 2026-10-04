extends CenterContainer

# Read-only view of what the player owns. Opened with the "inventory" action
# from anywhere, or by another panel calling open().
#
# It only reads Inventory - buying happens in the shop, and nothing here
# grants, spends or consumes an item.

const DETAIL := "PanelContainer/MarginContainer/VBoxContainer/Body/Detail/VBoxContainer"

@onready var item_list: ItemList = $PanelContainer/MarginContainer/VBoxContainer/Body/ItemList
@onready var summary: Label = $PanelContainer/MarginContainer/VBoxContainer/Summary
@onready var preview: TextureRect = get_node(DETAIL + "/Preview")
@onready var name_label: Label = get_node(DETAIL + "/Name")
@onready var description: Label = get_node(DETAIL + "/Description")
@onready var owned_label: Label = get_node(DETAIL + "/Owned")
@onready var value_label: Label = get_node(DETAIL + "/Value")

# Items in list order, so a list index maps back to a ShopItem
var _items: Array[ShopItem] = []

# Item under the cursor, kept rather than the index so the selection survives a
# rebuild that reorders the list.
var _selected: ShopItem = null

func _ready() -> void:
	visible = false
	add_to_group("inventory_ui")
	UIManager.register(self)
	item_list.item_selected.connect(_on_item_selected)
	Inventory.changed.connect(_rebuild)
	_rebuild()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	_rebuild()
	visible = true

func close() -> void:
	visible = false

# ==== PRIVATE ====

func _rebuild() -> void:
	_items = Inventory.all_items()
	item_list.clear()
	for item in _items:
		var index := item_list.add_item("%s  x%d" % [item.title, Inventory.owned_count(item)], item.icon)
		item_list.set_item_tooltip(index, item.description)

	# Whatever was selected may have been used up since the last rebuild
	if _selected != null and not _items.has(_selected):
		_selected = null
	if _selected == null and not _items.is_empty():
		_selected = _items[0]
	if _selected != null:
		item_list.select(_items.find(_selected))

	summary.text = "%d items · %d types · $%d value" % [
		Inventory.total_count(),
		_items.size(),
		Inventory.total_value(),
	]
	_refresh_detail()

func _refresh_detail() -> void:
	if _selected == null:
		preview.texture = null
		name_label.text = "Chưa có gì"
		description.text = ""
		owned_label.text = ""
		value_label.text = ""
		return
	var count := Inventory.owned_count(_selected)
	preview.texture = _selected.icon
	name_label.text = _selected.title
	description.text = _selected.description
	owned_label.text = "Owned: %d" % count
	value_label.text = "$%d each · $%d total" % [_selected.price, _selected.price * count]

func _on_item_selected(index: int) -> void:
	_selected = _items[index] if index >= 0 and index < _items.size() else null
	_refresh_detail()

func _on_close_btn_pressed() -> void:
	close()

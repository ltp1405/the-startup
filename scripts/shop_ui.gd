extends CenterContainer

const DETAIL := "PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer"
const LIST := "PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/TabContainer/All Items/ItemList"
@onready var item_list: ItemList = get_node(LIST)
@onready var preview: TextureRect = get_node(DETAIL + "/TextureRect")
@onready var description: Label = get_node(DETAIL + "/Label")
@onready var price_label: Label = get_node(DETAIL + "/Price")
@onready var buy_btn: Button = get_node(DETAIL + "/BuyBtn")
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/Title

const EMPTY: Array[ShopItem] = []

var _catalog: ShopCatalog
var _items: Array[ShopItem] = []
var _selected := -1

func _ready() -> void:
	add_to_group("shop_ui")
	UIManager.register(self)
	Inventory.purchased.connect(_on_purchased)
	GameManager.money_changed.connect(_on_money_changed)
	_rebuild()

# Opened by a shop node, which supplies its own stock.
func open(catalog: ShopCatalog, shop_name: String = "Shop") -> void:
	_catalog = catalog
	_selected = -1
	title_label.text = shop_name.to_upper()
	_rebuild()
	visible = true

func _rebuild() -> void:
	_items = _catalog.items if _catalog else EMPTY
	item_list.clear()
	for item in _items:
		var index := item_list.add_item(item.title, item.icon)
		var owned := Inventory.owned_count(item)
		if owned > 0:
			item_list.set_item_text(index, "%s (x%d)" % [item.title, owned])
	if _selected >= _items.size():
		_selected = -1
	if _selected >= 0:
		item_list.select(_selected)
	_refresh_detail()

func _selected_item() -> ShopItem:
	if _selected < 0 or _selected >= _items.size():
		return null
	return _items[_selected]

func _refresh_detail() -> void:
	var item := _selected_item()
	if item == null:
		preview.texture = null
		description.text = "Chọn một món"
		price_label.text = ""
		buy_btn.disabled = true
		return
	preview.texture = item.icon
	description.text = item.description
	price_label.text = "$%d" % item.price
	buy_btn.disabled = not Inventory.can_buy(item)

# ==== SIGNALS ====

func _on_item_list_item_selected(index: int) -> void:
	_selected = index
	_refresh_detail()

func _on_buy_btn_pressed() -> void:
	var item := _selected_item()
	if item != null:
		Inventory.buy(item)

func _on_purchased(_item: ShopItem) -> void:
	_rebuild()

func _on_money_changed(_money: int) -> void:
	_refresh_detail()

func _on_close_btn_pressed() -> void:
	visible = false

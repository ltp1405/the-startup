extends Node

# What the player owns, and the rules for buying it.
#
# Deliberately knows nothing about shops: a catalog is per-shop data that lives
# on the shop node. This only answers "can I afford it" and "what do I have".

signal purchased(item: ShopItem)
signal purchase_failed(item: ShopItem, reason: String)
# Anything that changes what the player owns, bought or granted.
signal changed

# ShopItem -> how many the player owns
var owned: Dictionary = {}

func owned_count(item: ShopItem) -> int:
	return owned.get(item, 0)

func has(item: ShopItem) -> bool:
	return owned_count(item) > 0

func can_buy(item: ShopItem) -> bool:
	return item != null and GameManager.can_afford(item.price)

func buy(item: ShopItem) -> bool:
	if item == null:
		return false
	if not GameManager.can_afford(item.price):
		purchase_failed.emit(item, "Không đủ tiền")
		return false
	if not GameManager.spend(item.price):
		purchase_failed.emit(item, "Không trả được")
		return false
	add(item)
	purchased.emit(item)
	return true

# Grants an item without charging for it (rewards, starting kit)
func add(item: ShopItem, count: int = 1) -> void:
	if item == null or count <= 0:
		return
	owned[item] = owned_count(item) + count
	changed.emit()

# Takes items away (consumed, sold, lost). Returns false if the player does not
# have that many.
func remove(item: ShopItem, count: int = 1) -> bool:
	if item == null or count <= 0 or owned_count(item) < count:
		return false
	var left := owned_count(item) - count
	if left > 0:
		owned[item] = left
	else:
		owned.erase(item)
	changed.emit()
	return true

# Every owned item, ordered by title so the list does not jump around.
func all_items() -> Array[ShopItem]:
	var items: Array[ShopItem] = []
	items.assign(owned.keys())
	items.sort_custom(func(a, b): return a.title < b.title)
	return items

func total_count() -> int:
	var total := 0
	for item in owned:
		total += owned[item]
	return total

func total_value() -> int:
	var total := 0
	for item in owned:
		total += item.price * owned[item]
	return total

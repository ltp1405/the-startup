extends MarginContainer

@onready var day_label: Label = $HBoxContainer/Label
@onready var time_label: Label = $HBoxContainer/Label2
@onready var money_label: Label = $HBoxContainer/Label3

func _ready() -> void:
	TimeManager.tick.connect(_on_tick)
	TimeManager.day_started.connect(_on_day_started)
	_refresh()

func _on_tick(_total_tick: int) -> void:
	_refresh()

func _on_day_started(_day: int) -> void:
	_refresh()

func _refresh() -> void:
	day_label.text = "Day %d" % TimeManager.day
	time_label.text = TimeManager.time_string()
	# GameManager has no money_changed signal yet, so this rides the tick
	money_label.text = "Money %d" % GameManager.money

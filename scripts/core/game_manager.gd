extends Node

@export var money = 100

# Bills that will be charged the next day
@export var bills = []

signal bill_charged
signal day_passed
signal day_started

func _ready() -> void:
	TimeManager.day_started.connect(_on_day_started)

func get_today_bill():
	return {
		"remain": money,
		"bills": [
			{
				"expense": 10,
				"description": "Điện",
			}
		],
		"upcoming_bills": [],
	}
	
func confirm_pay_bill():
	pass

# Payout for a finished task. Called by TaskManager, which owns task state.
func finish_task(task: Task):
	money += task.money

# ==== PRIVATE ====

func _begin_morning() -> void:
	day_started.emit()
	_charge_bill()
	# bill_charged.emit()
	# wait for confirm_pay_bill() to continue

func _charge_bill() -> void:
	var next_bills = []

func _on_day_started(_day: int) -> void:
	_begin_morning()

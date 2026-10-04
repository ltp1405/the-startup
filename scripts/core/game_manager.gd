extends Node

@export var money := 200

# Bills that will be charged the next day
@export var bills = []

signal money_changed(money: int)
signal bill_charged
signal day_passed
signal day_started

func _ready() -> void:
	# Deferred so this does not depend on autoload registration order
	_connect_clock.call_deferred()

func _connect_clock() -> void:
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
	money_changed.emit(money)

func can_afford(amount: int) -> bool:
	return money >= amount

func spend(amount: int) -> bool:
	if amount < 0 or not can_afford(amount):
		return false
	money -= amount
	money_changed.emit(money)
	return true

# ==== PRIVATE ====

func _begin_morning() -> void:
	day_started.emit()
	_charge_bill()
	# bill_charged.emit()
	# wait for confirm_pay_bill() to continue

func _charge_bill() -> void:
	var pay_salary = TimeManager.day % 7 == 0
	if pay_salary:
		var sum := 0
		for worker in WorkerManager.roaster:
			sum += worker.wage
			
		spend(sum)

func _on_day_started(_day: int) -> void:
	_begin_morning()

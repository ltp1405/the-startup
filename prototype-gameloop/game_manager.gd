extends Object

@export var money = 100

# Bills that will be charged the next day
@export var bills = []

signal bill_charged
signal task_assigned
signal day_passed
signal day_started

func _input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		_begin_morning()
	
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

func assign_task():
	task_assigned.emit()

# ==== PRIVATE ====

func _begin_morning() -> void:
	day_started.emit()
	_charge_bill()
	bill_charged.emit()
	# wait for confirm_pay_bill() to continue

func _charge_bill() -> void:
	var next_bills = []

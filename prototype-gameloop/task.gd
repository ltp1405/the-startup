class_name Task
extends Resource

@export var title: int
@export var energy: int
@export var description: String
@export var day: int
@export var money: int
@export var customer: Customer

func _init(p_energy = 0, p_description = "", p_day = 1, p_money = 0,
	p_customer = null):
	energy = p_energy
	description = p_description
	day = p_day
	money = p_money
	customer = p_customer

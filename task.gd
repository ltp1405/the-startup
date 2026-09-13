class_name Task
extends Resource

@export var title: String
@export var energy: int
@export var description: String
@export var time: int
@export var money: int
@export var customer: Customer
@export var deadline: int

func _init(p_energy = 0, p_description = "", p_time = 1, p_money = 0,
	p_customer = null, p_title = "", p_deadline = 1):
	energy = p_energy
	description = p_description
	time = p_time
	money = p_money
	customer = p_customer
	title = p_title
	deadline = p_deadline

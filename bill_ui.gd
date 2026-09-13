extends CenterContainer

var today_bill_container: VBoxContainer
var upcoming_bill_container: VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.bill_charged.connect(_on_bill_charged)
	today_bill_container = %BillList
	upcoming_bill_container = %UpcomingBillList
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_bill_charged() -> void:
	print("Charged")
	_load_bill_data()
	_show_ui()
	
func _on_close_btn_pressed() -> void:
	GameManager.confirm_pay_bill()
	_hide_ui()

func _load_bill_data() -> void:
	var bill_data = GameManager.get_today_bill()
	_populate_bills(today_bill_container, bill_data["bills"])
	_populate_bills(upcoming_bill_container, bill_data["upcoming_bills"])

	%Remaining.text = "Số tiền còn lại: %s" %  bill_data["remain"]

func _show_ui() -> void:
	visible = true

func _hide_ui() -> void:
	visible = false

func _populate_bills(container: Container, bills):
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		
	for bill in bills:
		var label = Label.new()
		label.text = "%s -%s" % [bill["description"], bill["expense"]]
		today_bill_container.add_child(label)

extends Node

enum HireStatus { CANNOT_HIRE, HIRED, NOT_HIRED }

@onready var debug_label = $"../Node2D/Label"
var worker: WorkerData
var worker_template: WorkerData
var hire_status := HireStatus.NOT_HIRED

signal task_started
signal task_finished

func setup(w: WorkerData):
	worker_template = w
	worker = w
	_update_debug_info()
	_sync_hire_status()

func _ready() -> void:
	TaskManager.task_assigned.connect(_on_task_assigned)
	TaskManager.task_progressed.connect(_on_task_progressed)
	TaskManager.task_finished.connect(_on_task_finished)
	_sync_hire_status()

# ==== TASK DISPLAY ====

func _on_task_assigned(_task: Task, w: WorkerData) -> void:
	_update_debug_info()
	task_started.emit()

func _on_task_progressed(_task: Task, w: WorkerData, remaining: int) -> void:
	_update_debug_info()

func _on_task_finished(_task: Task, w: WorkerData) -> void:
	_update_debug_info()
	task_finished.emit()

func get_worker() -> WorkerData:
	return worker

func is_busy():
	return TaskManager.is_busy(worker)


func hire() -> bool:
	if hire_status != HireStatus.NOT_HIRED or worker_template == null:
		return false
	if not GameManager.spend(worker_template.wage):
		push_warning("Cannot afford to hire %s ($%d)" % [worker_template.name, worker_template.wage])
		return false
	worker = WorkerManager.hire(worker_template)
	hire_status = HireStatus.HIRED
	_update_debug_info()
	return true

func _update_debug_info():
	var debug_text = ""
	var worker_text
	match hire_status:
		HireStatus.CANNOT_HIRE:
			worker_text = "cannot hire"
		HireStatus.HIRED:
			var task = TaskManager.task_of(worker)
			if task != null:
				worker_text = "working"
			else:
				worker_text = "hired"
			
		HireStatus.NOT_HIRED:
			worker_text = "not hired"

	debug_text += "%s\n" % worker_text
	
	debug_label.text = debug_text

# Looks this NPC up on the payroll. hire_status is derived, not stored: whether
# WorkerManager already knows the id decides it, so a scene reload cannot lose a
# hire or enrol the same person twice.
func _sync_hire_status() -> void:
	if hire_status == HireStatus.CANNOT_HIRE or worker_template == null:
		worker = null
		return
	worker = WorkerManager.find(worker_template.id)
	if worker == null and hire_status == HireStatus.HIRED:
		# Authored as starting staff: enrol once, for free. hire() is idempotent
		# by id, so a later scene reload finds them above instead of enrolling a
		# second copy.
		worker = WorkerManager.hire(worker_template)
	hire_status = HireStatus.HIRED if worker != null else HireStatus.NOT_HIRED
	_update_debug_info()

func can_hire():
	return hire_status == HireStatus.NOT_HIRED

func assign_task():
	var ui = get_tree().get_first_node_in_group("choose_task_ui")
	if ui:
		ui.open_for(self)

func can_assign_task():
	return true

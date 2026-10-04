extends Node

# The studio's payroll.
#
# This autoload survives scene changes; the NPC nodes in a scene do not. So this
# is the source of truth for who works here, and an NPC node is only a view onto
# it: on load an NPC looks its Worker up by id rather than pushing a new one.
#
# Workers on the payroll are always copies of their .tres template, so runtime
# changes (wage rises, shift moves) never write back to the resource on disk.

signal shift_started(worker: WorkerData)
signal shift_ended(worker: WorkerData)
signal hired(worker: WorkerData)

var roaster: Array[WorkerData] = []
var in_shift: Array[WorkerData] = []

# ==== PUBLIC ====

func is_in_shift(worker: WorkerData) -> bool:
	return worker != null and in_shift.has(worker)

# The live Worker for an id, or null if nobody with that id is on the payroll.
func find(id: StringName) -> WorkerData:
	if id == &"":
		return null
	for worker in roaster:
		if worker.id == id:
			return worker
	return null

func is_hired(id: StringName) -> bool:
	return find(id) != null

# Puts a copy of the template on the payroll and returns the live instance.
# Hiring someone already on it is a no-op that returns who is already there.
func hire(template: WorkerData) -> WorkerData:
	if template == null:
		return null
	assert(template.id != &"", "Worker resource needs an id to be hired")
	var existing := find(template.id)
	if existing != null:
		return existing

	var worker: WorkerData = template.duplicate()
	roaster.push_back(worker)
	# Hired mid-shift, so they start working now rather than waiting for the
	# next shift_start hour to come round.
	if _is_working_hour(worker, TimeManager.hour()):
		in_shift.push_back(worker)
		shift_started.emit(worker)
	hired.emit(worker)
	return worker

# ==== PRIVATE ====

func _ready() -> void:
	_connect_clock.call_deferred()

func _connect_clock() -> void:
	TimeManager.hour_changed.connect(_on_hour_changed)

# Shifts that run past midnight (start 22, end 6) wrap, so this is not a plain
# start <= h < end comparison.
func _is_working_hour(worker: WorkerData, h: int) -> bool:
	if worker.shift_start == worker.shift_end:
		return false
	if worker.shift_start < worker.shift_end:
		return h >= worker.shift_start and h < worker.shift_end
	return h >= worker.shift_start or h < worker.shift_end

func _on_hour_changed(hour: int) -> void:
	for worker in roaster:
		var working := _is_working_hour(worker, hour)
		var listed := in_shift.has(worker)
		if working and not listed:
			in_shift.push_back(worker)
			shift_started.emit(worker)
		elif not working and listed:
			in_shift.erase(worker)
			shift_ended.emit(worker)

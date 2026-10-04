class_name WorkerData

extends Resource

# Stable identity, unique per worker resource. WorkerManager keys the payroll on
# this, so a hired copy can be matched back to its .tres across scene loads.
@export var id: StringName

@export var name: String
@export var portrail: Texture

@export var shift_start := 9
@export var shift_end := 17
@export var wage := 0

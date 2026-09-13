extends CanvasModulate

# Tints the scene by time of day. Sampled every frame from TimeManager.day_progress(),
# which interpolates between ticks, so the light moves smoothly rather than stepping.

@export var enabled := true

var _gradient: Gradient

func _ready() -> void:
	_gradient = Gradient.new()
	_gradient.offsets = PackedFloat32Array()
	_gradient.colors = PackedColorArray()
	# offset = fraction of the day (0.0 = midnight, 0.5 = noon)
	_add(0.00, Color(0.30, 0.34, 0.58))   # midnight
	_add(0.21, Color(0.32, 0.36, 0.60))   # 5:00, still night
	_add(0.29, Color(0.85, 0.66, 0.60))   # 7:00, dawn
	_add(0.38, Color(1.00, 0.99, 0.96))   # 9:00, full day
	_add(0.67, Color(1.00, 0.97, 0.90))   # 16:00
	_add(0.79, Color(0.95, 0.66, 0.45))   # 19:00, dusk
	_add(0.88, Color(0.45, 0.44, 0.68))   # 21:00
	_add(1.00, Color(0.30, 0.34, 0.58))   # wraps to midnight

func _add(offset: float, colour: Color) -> void:
	_gradient.add_point(offset, colour)

func _process(_delta: float) -> void:
	if not enabled:
		return
	color = _gradient.sample(TimeManager.day_progress())

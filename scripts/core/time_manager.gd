extends Node

# Real-time game clock. Single source of time for the whole game.
#
# A tick is MINUTES_PER_TICK of in-game time and seconds_per_tick of real time.
# Everything that advances with time should listen to `tick`, not run its own Timer.

const MINUTES_PER_TICK := 30
const TICKS_PER_DAY := 48          # 24h
const DAY_START_TICK := 16         # 8:00
const SECONDS_PER_TICK := 5

enum Phase { DAWN, DAY, DUSK, NIGHT }

signal tick(total_tick: int)
signal hour_changed(hour: int)
signal phase_changed(phase: Phase)
signal day_started(day: int)
signal day_ended(day: int)

var day := 1
var tick_of_day := DAY_START_TICK
var seconds_per_tick := SECONDS_PER_TICK:
	set(value):
		seconds_per_tick = value
		if _timer:
			_timer.wait_time = value
			# wait_time alone does not affect a timer already counting down
			if not _timer.is_stopped():
				_timer.start()

var paused := false:
	set(value):
		paused = value
		if _timer:
			_timer.paused = value

var _timer: Timer
var _last_hour := -1
var _phase := Phase.DAY

func _ready() -> void:
	_timer = Timer.new()
	_timer.wait_time = seconds_per_tick
	_timer.autostart = true
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)

	_last_hour = hour()
	_phase = _phase_for_hour(_last_hour)
	# Deferred: autoloads registered after this one have not connected yet
	day_started.emit.call_deferred(day)

# ==== QUERIES ====

func hour() -> int:
	return (tick_of_day * MINUTES_PER_TICK) / 60

func minute() -> int:
	return (tick_of_day * MINUTES_PER_TICK) % 60

func phase() -> Phase:
	return _phase

func total_tick() -> int:
	return (day - 1) * TICKS_PER_DAY + tick_of_day

func time_string() -> String:
	var h := hour()
	var suffix := "AM" if h < 12 else "PM"
	var display := h % 12
	if display == 0:
		display = 12
	return "%d:%02d %s" % [display, minute(), suffix]

# 0..1 through the day, interpolated between ticks so lighting moves smoothly.
func day_progress() -> float:
	var fraction := 0.0
	if _timer and _timer.wait_time > 0.0 and not _timer.is_stopped():
		fraction = 1.0 - (_timer.time_left / _timer.wait_time)
	return (float(tick_of_day) + fraction) / float(TICKS_PER_DAY)

# Converts in-game hours (how tasks are authored) into ticks.
func hours_to_ticks(hours: int) -> int:
	return int(round(float(hours) * 60.0 / float(MINUTES_PER_TICK)))

func ticks_to_hours(ticks: int) -> float:
	return float(ticks) * float(MINUTES_PER_TICK) / 60.0

# ==== CONTROL ====

func set_paused(value: bool) -> void:
	paused = value

func set_speed(seconds: float) -> void:
	seconds_per_tick = maxf(0.05, seconds)

# ==== PRIVATE ====

func _on_timer_timeout() -> void:
	tick_of_day += 1
	if tick_of_day >= TICKS_PER_DAY:
		tick_of_day = 0
		day_ended.emit(day)
		day += 1
		day_started.emit(day)

	tick.emit(total_tick())

	var h := hour()
	if h != _last_hour:
		_last_hour = h
		hour_changed.emit(h)

	var p := _phase_for_hour(h)
	if p != _phase:
		_phase = p
		phase_changed.emit(p)

func _phase_for_hour(h: int) -> Phase:
	if h >= 5 and h < 8:
		return Phase.DAWN
	if h >= 8 and h < 17:
		return Phase.DAY
	if h >= 17 and h < 20:
		return Phase.DUSK
	return Phase.NIGHT

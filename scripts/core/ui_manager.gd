extends Node

# Freezes the world while any modal UI is on screen.
#
# Panels call register(self) once in _ready(). This watches their
# visibility_changed and pauses the SceneTree whenever at least one is open, so
# the player stops walking and the clock stops ticking behind a menu.
#
# The panels themselves keep running because the "ui" CanvasLayer they live
# under is PROCESS_MODE_ALWAYS - pausing does not reach it.

signal blocking_changed(is_blocking: bool)

# Every panel currently visible
var _open: Array[Node] = []

# Every panel that has registered, so a panel is never wired up twice
var _registered: Array[Node] = []

func register(panel: CanvasItem) -> void:
	if panel == null or _registered.has(panel):
		return
	_registered.append(panel)
	panel.visibility_changed.connect(_on_visibility_changed.bind(panel))
	panel.tree_exiting.connect(_forget.bind(panel))
	_on_visibility_changed(panel)

# True while at least one modal panel is open.
func is_blocking() -> bool:
	return not _open.is_empty()

# ==== PRIVATE ====

func _on_visibility_changed(panel: CanvasItem) -> void:
	if panel.is_visible_in_tree():
		if not _open.has(panel):
			_open.append(panel)
	else:
		_open.erase(panel)
	_apply()

func _forget(panel: Node) -> void:
	_registered.erase(panel)
	_open.erase(panel)
	_apply()

func _apply() -> void:
	var should_pause := is_blocking()
	if get_tree().paused == should_pause:
		return
	get_tree().paused = should_pause
	blocking_changed.emit(should_pause)

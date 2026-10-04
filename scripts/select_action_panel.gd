extends CenterContainer

# Popup shown when interacting with an NPC that offers more than one thing to do.
#
# Purely a chooser: it hands the picked action id straight back to the NPC via
# do_interaction() and never touches task, worker or money state itself.

# action id -> button text
const ACTION_LABELS := {
	"assign_task": "Assign task",
	"unassign_task": "Pull off task",
	"give_task": "Talk",
	"hire": "Hire",
}

@onready var actions_list: HBoxContainer = $PanelContainer/HBoxContainer2/HBoxContainer

# NPC the panel was opened for
var npc: Object = null

func _ready() -> void:
	visible = false
	add_to_group("select_action_panel")
	UIManager.register(self)

func open_for(p_npc: Object, actions: Array[String]) -> void:
	npc = p_npc
	_build(actions)
	visible = true

func close() -> void:
	npc = null
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

# ==== PRIVATE ====

func _build(actions: Array[String]) -> void:
	for child in actions_list.get_children():
		# Detached first: queue_free() only frees at the end of the frame, and the
		# panel can be reopened before then.
		actions_list.remove_child(child)
		child.queue_free()

	var first: Button = null
	for action in actions:
		var btn := Button.new()
		btn.text = ACTION_LABELS.get(action, action)
		btn.pressed.connect(_on_action_pressed.bind(action))
		actions_list.add_child(btn)
		if first == null:
			first = btn
	if first != null:
		# So the panel swallows the next ui_accept instead of the player
		# re-interacting with the NPC behind it.
		first.grab_focus()

func _on_action_pressed(action: String) -> void:
	var target := npc
	close()
	if target != null and is_instance_valid(target) and target.has_method("do_interaction"):
		target.do_interaction(action)

func _on_close_pressed() -> void:
	close()

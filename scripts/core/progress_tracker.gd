extends Node

const KNOWN_PROGRESSES = [
	"first_task_finished",
]

var achived_progresses: Array[String] = []

func _on_ready():
	pass

func satisfied(progresses: Array[String]) -> bool:
	return false

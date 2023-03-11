extends Resource
class_name external_signals

const PATH = "user://external_signals.tres"

@export var currently_quizzing = false
@export var success = false

func write():
	ResourceSaver.save(self, PATH)
		
func read():
	if ResourceLoader.exists(PATH):
		return load(PATH)
	return null


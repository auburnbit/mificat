extends Resource
class_name SaveData

const PATH = "user://save.tres"

@export var dict : Dictionary

func save_card_data():
	ResourceSaver.save(self, PATH)
		
func load_card_data():
	if ResourceLoader.exists(PATH):
		return load(PATH)
	return null

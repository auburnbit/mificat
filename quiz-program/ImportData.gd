extends Node

var question_data

func _ready():
	question_data = read_json()
	print (str(typeof(question_data)))
	
func read_json():	
	var questiondata_file = FileAccess.open("res://data/question_data.json", FileAccess.READ)
	var json_object = JSON.new()
	var parse_err = json_object.parse(questiondata_file.get_as_text())
	return json_object.get_data()

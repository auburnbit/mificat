extends Node
var all_keys_array = []
var all_cards = []
var churn_max_size = 20

var dict = {
	"0":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "LTS Unity release as of March 3rd, 2023",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "2021.3",
		"AnswerType": "number",
	},
	"1":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to create a new empty GameObject",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "Ctrl+Shift+N",
		"AnswerType": "hotkey",
	},
	"2":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to toggle visibility of all descendant GameObjects of the root GameObject",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "Alt while clicking the drop-down arrow",
		"AnswerType": "hotkey",
	},
	"3":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to duplicate GameObjects",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "Ctrl+D",
		"AnswerType": "hotkey",
	},
	"4":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to paste a GameObject as a child",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "Ctrl+Shift+V",
		"AnswerType": "hotkey",
	},
	"5":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, use this unless noted otherwise",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "PascalCase",
		"AnswerType": "formatting",
	},
	"6":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing local/private variables and parameters, use this",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "camelCase",
		"AnswerType": "formatting",
	},
	"7":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, avoid these",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "snake_case, kebab-case, and Hungarian notation",
		"AnswerType": "formatting",
	},
	"8":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, if you have this in a file, the source file name must match",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "MonoBehaviour",
		"AnswerType": "class",
	},
	"9":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For formatting, choose one of these for braces",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "K&R or Allman",
		"AnswerType": "formatting",
	},
	"10":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For formatting, choose a max line width in the range of this many characters",
		"Image": "none",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "80 and 120",
		"AnswerType": "number",
	},
	"11":{
		"QuestionType": "true or false",
		"Category": "Laundry",
		"Prompt": "These are pajamas.",
		"Image": "11.jpg",
		"InChurn": false,
		"RepsAtLeast3": 0,
		"RepsAtLeast4": 0,
		"RepsAtLeast5": 0,
		"TimeLeftChurn": 0,
		"Answer": "true",
		"AnswerType": "number",
	},
}

func _ready():
	for key in dict.keys():
		all_keys_array.append(key)
	
	for key in dict.keys():
		
		var card = Card.new()
		
		card.unique_key 		= key
		card.question_type 		= dict.get(key).get("QuestionType")
		card.category 			= dict.get(key).get("Category")
		card.prompt 			= dict.get(key).get("Prompt")
		card.image 				= dict.get(key).get("Image")
		card.in_churn 			= dict.get(key).get("InChurn")
		card.reps_at_least_3 	= dict.get(key).get("RepsAtLeast3")
		card.reps_at_least_4 	= dict.get(key).get("RepsAtLeast4")
		card.reps_at_least_5 	= dict.get(key).get("RepsAtLeast5")
		card.time_left_churn 	= dict.get(key).get("TimeLeftChurn")
		card.answer 			= dict.get(key).get("Answer")
		card.answer_type 		= dict.get(key).get("AnswerType")
		
		card.determine_wrong_answers()
		
		all_cards.append(card)
		
	for card in all_cards:
		card.randomize_answers()
		
	all_cards.sort_custom(sort_by_time_oldest_first)		

func sort_by_time_oldest_first(a, b):
	if a.time_left_churn < b.time_left_churn:
		return true
	return false




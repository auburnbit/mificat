extends Node
var all_keys_array = []

var dict = {
	"0":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "LTS Unity release as of March 3rd, 2023",
		"Image": "none",
		"Answer": "2021.3",
		"AnswerType": "number",
	},
	"1":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to create a new empty GameObject",
		"Image": "none",
		"Answer": "Ctrl+Shift+N",
		"AnswerType": "hotkey",
	},
	"2":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to toggle visibility of all descendant GameObjects of the root GameObject",
		"Image": "none",
		"Answer": "Alt while clicking the drop-down arrow",
		"AnswerType": "hotkey",
	},
	"3":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to duplicate GameObjects",
		"Image": "none",
		"Answer": "Ctrl+D",
		"AnswerType": "hotkey",
	},
	"4":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "The hotkey to paste a GameObject as a child",
		"Image": "none",
		"Answer": "Ctrl+Shift+V",
		"AnswerType": "hotkey",
	},
	"5":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, use this unless noted otherwise",
		"Image": "none",
		"Answer": "PascalCase",
		"AnswerType": "formatting",
	},
	"6":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing local/private variables and parameters, use this",
		"Image": "none",
		"Answer": "camelCase",
		"AnswerType": "formatting",
	},
	"7":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, avoid these",
		"Image": "none",
		"Answer": "snake_case, kebab-case, and Hungarian notation",
		"AnswerType": "formatting",
	},
	"8":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For naming/casing, if you have this in a file, the source file name must match",
		"Image": "none",
		"Answer": "MonoBehaviour",
		"AnswerType": "class",
	},
	"9":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For formatting, choose one of these for braces",
		"Image": "none",
		"Answer": "K&R or Allman",
		"AnswerType": "formatting",
	},
	"10":{
		"QuestionType": "multiple choice",
		"Category": "Unity",
		"Prompt": "For formatting, choose a max line width in the range of this many characters",
		"Image": "none",
		"Answer": "80 and 120",
		"AnswerType": "number",
	},
	"11":{
		"QuestionType": "true or false",
		"Category": "Laundry",
		"Prompt": "These are pajamas.",
		"Image": "11.jpg",
		"Answer": "true",
		"AnswerType": "number",
	},
}

func _ready():
	for key in dict.keys():
		all_keys_array.append(key)

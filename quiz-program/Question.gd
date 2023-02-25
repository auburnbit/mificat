class_name Question extends Node

var term = "none"
var category = "none"
var definition = "none"
var user_grade = "0"
var rep_number = "0"
var easiness = "0"
var interval = "0"
var last_date_and_time = "never"
var correct_answer_index = "0"
var answers = []

func print_all():
	print("term: " + term)
	print("category: " + category)
	print("definition: " + definition)
	print("user_grade: " + user_grade)
	print("rep_number: " + rep_number)
	print("easiness: " + easiness)
	print("interval: " + interval)
	print("last_date_and_time: " + last_date_and_time)
	print("correct_answer_index: " + correct_answer_index)
	print("answers[0]: " + answers[0])
	print("answers[1]: " + answers[1])
	print("answers[2]: " + answers[2])
	print("answers[3]: " + answers[3])	
	
func print_term_and_definition():
	print("term: " + term + "    definition: " + definition)

func print_answer_selection():
	match correct_answer_index:
		0:
			print("Answer Selection: " + "   *" + answers[0] + "    " + answers[1] + "    " + answers[2] + "    " + answers[3])
		1:
			print("Answer Selection: " + "    " + answers[0] + "   *" + answers[1] + "    " + answers[2] + "    " + answers[3])
		2:	
			print("Answer Selection: " + "    " + answers[0] + "    " + answers[1] + "   *" + answers[2] + "    " + answers[3])
		3:
			print("Answer Selection: " + "    " + answers[0] + "    " + answers[1] + "    " + answers[2] + "   *" + answers[3])

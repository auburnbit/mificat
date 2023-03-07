class_name Card extends Node

var unique_key = "none"
var question_type = "none"
var category = "none"
var wrong_answers = []
var prompt = "none"
var image = "none"
var answer = "none"
var answer_type = "none"
var answer_list = []
var correct_index = 0
var in_churn = false
var reps_at_least_3 = 0
var reps_at_least_4 = 0
var reps_at_least_5 = 0
var time_left_churn = "none"

func determine_wrong_answers():
	
	#multiple choice gets same types of wrong answers from other cards
	if question_type == "multiple choice":
		var dict = CardDict.dict
		for key in dict.keys():
			
			#grabbing necessary info from other card
			var other_qt = dict.get(key).get("QuestionType")
			var other_at = dict.get(key).get("AnswerType")
			var other_ans = dict.get(key).get("Answer")
			
			#other card must be multiple choice, must be same type of answer
			#can't be exact same answer, and must be a new wrong answer
			if  other_qt == "multiple choice" \
				and other_at == answer_type \
				and other_ans != answer \
				and !wrong_answers.has(other_ans):				
					wrong_answers.append(other_ans)
					
		#if not enough answers of that type, notify user
		while wrong_answers.size() < 3:
			wrong_answers.append("need more " + answer_type + " answers") 
	
	#true or false questions just get opposite as only wrong answer
	elif question_type == "true or false":
		if answer == "true":
			wrong_answers.append("false")
		else:
			wrong_answers.append("true")
				
func randomize_answers():
	if question_type == "multiple choice":
		answer_list.clear()
		answer_list.append(answer) #putting right answer in answer list
		
		#then put in other three other wrong answers at random
		wrong_answers.shuffle()
		answer_list.append(wrong_answers[0])
		answer_list.append(wrong_answers[1])	
		answer_list.append(wrong_answers[2])
		
		#shuffle the answer list and identify index of correct answer
		answer_list.shuffle()
		correct_index = answer_list.find(answer)
		
	elif question_type == "true or false":
		answer_list.clear()
		answer_list.append("true")
		answer_list.append("false")
		#no need to shuffle, just keep true on left always
		correct_index = answer_list.find(answer)
		
	print("-----------")
	print(prompt)
	print(answer)
	print(answer_list)	

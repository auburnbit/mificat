extends Node

var save_data = preload("res://save.tres")
#var save_data = SaveData.new()
var dict = save_data.dict

var all_keys_array = []
var all_cards = []
var quiz_cards = []
var churn_max_size = 20
var json = JSON.new()

var in_churn = false
var reps_at_least_3 = 0
var reps_at_least_4 = 0
var reps_at_least_5 = 0
var time_left_churn = "none"

var churn = []
var not_churn = []
	
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
		if card.in_churn == true:
			churn.append(card)
		
	for card in all_cards:
		card.randomize_answers()
	
	#NEED TO HANDLE DIFFERENTLY, SAVED CHURN CARDS MUST GO IN CHURN FIRST	
	all_cards.sort_custom(sort_by_time_oldest_first)
	grab_random_cards_from_churn(5)		

func sort_by_time_oldest_first(a, b):
	if a.time_left_churn < b.time_left_churn:
		return true
	return false
	
func grab_random_cards_from_churn(number_to_grab):
	churn = all_cards.slice(0, churn_max_size - 1)
	not_churn = all_cards.slice(churn_max_size, all_cards.size())
	quiz_cards = []
	for i in number_to_grab:
		quiz_cards.append(churn.pop_at(randi() % churn.size()))
	print(quiz_cards)
	return quiz_cards





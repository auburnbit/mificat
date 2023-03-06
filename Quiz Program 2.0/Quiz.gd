extends Node2D

var card_number = 0
var cards = []
var dict = QuestionDict.dict

func _ready():
	for key in dict.keys():
		var card = Card.new()		
		card.unique_key = key
		card.question_type = dict.get(key).get("QuestionType")
		card.category = dict.get(key).get("Category")
		card.prompt = dict.get(key).get("Prompt")
		card.image = dict.get(key).get("Image")
		card.answer = dict.get(key).get("Answer")
		card.answer_type = dict.get(key).get("AnswerType")
		card.determine_wrong_answers()
		cards.append(card)
	for card in cards:
		card.randomize_answers()

func _process(delta):
	if visible:
		var card = cards[card_number]
		$CategoryLabel/CategoryText.text = str(card.category)
		$Answer0.text = card.answer_list[0]
		$Answer1.text = card.answer_list[1]
		if card.question_type =="multiple choice":
			$Answer2.text = card.answer_list[2]
			$Answer3.text = card.answer_list[3]
		elif card.question_type =="true or false":
			$Answer2.text = ""
			$Answer3.text = ""
		if card.image == "none":		
			$PromptLabel/PromptText.text = card.prompt
			$PromptLabel/ImagePrompt.texture = load("res://card_images/no_image.jpg")
			$PromptLabel/ImagePromptText.text = ""			
			$PromptLabel/PromptText.visible = true
			$PromptLabel/ImagePrompt.visible = false
			$PromptLabel/ImagePromptText.visible = false
		else: 
			$PromptLabel/PromptText.text = ""
			$PromptLabel/ImagePrompt.texture = load("res://card_images/" + card.image)
			$PromptLabel/ImagePromptText.text = card.prompt			
			$PromptLabel/PromptText.visible = false
			$PromptLabel/ImagePrompt.visible = true
			$PromptLabel/ImagePromptText.visible = true	

func _input(event):
	if visible:
		if event.is_action_pressed("ui_left"):
			if card_number <= 0:
				card_number = cards.size() - 1
			else:
				card_number -= 1
		elif event.is_action_pressed("ui_right"):
			if card_number >= cards.size() - 1:
				card_number = 0
			else:
				card_number += 1

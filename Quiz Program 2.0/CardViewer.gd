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
		cards.append(card)

func _process(delta):
	if visible:
		var card = cards[card_number]
		$UniqueKeyLabel/UniqueKeyText.text = card.unique_key
		$CardNumberLabel/CardNumberText.text = str(card_number + 1)  + " of " + str(cards.size())
		$QuestionTypeLabel/QuestionTypeText.text = card.question_type
		$CategoryLabel/CategoryText.text = str(card.category)
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
		$AnswerLabel/AnswerText.text = card.answer
		$AnswerTypeLabel/AnswerTypeText.text = card.answer_type
		$AtLevelLabel/OptionButton.selected = int(card.level)
		$RepetitionLabel/RepetitionText.text = card.repitition
		$EasinessLabel/EasinessText.text = card.easiness
		$IntervalLabel/IntervalText.text = card.interval

func _on_next_button_button_down():
	if visible:
		if card_number >= cards.size() - 1:
			card_number = 0
		else:
			card_number += 1

func _on_prev_button_button_down():
	if visible:
		if card_number <= 0:
			card_number = cards.size() - 1
		else:
			card_number -= 1

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

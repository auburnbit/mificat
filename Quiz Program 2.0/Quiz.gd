extends Node2D

var card_number = 0
var dict = CardDict.dict
var cursorIndex = 0
var quiz_step = "prompt"
var got_question_correct = false

func _ready():
	pass

func _process(delta):
	if visible:
		
		update_cursor_draw_location()
		
		var card = CardDict.all_cards[card_number]
		$CategoryLabel/CategoryText.text = str(card.category)
		color_answers_appropriately()
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
			
		# perhaps make this show_feedback()
		if quiz_step == "prompt":
			$Feedback.visible = false
			$Answers.visible = false
			
		if quiz_step == "choices":
			$Feedback.visible = false
			$Answers.visible = true
			
		if quiz_step == "feedback":
			$Feedback.visible = true
			$Answers.visible = true
			match cursorIndex:
				0:
					$Feedback/FeedbackText.text = "[center]Did not know even after seeing choices.[/center]"
				1:
					$Feedback/FeedbackText.text = "[center]Did not know until after seeing choices.[/center]"
				2:
					$Feedback/FeedbackText.text = "[center]Wasn't certain before choices, or took far too long.[/center]"
				3:
					$Feedback/FeedbackText.text = "[center]Recited it without looking at choices, after thinking.[/center]"
				4:
					$Feedback/FeedbackText.text = "[center]Recited it without looking at choices, with only slight hesitation.[/center]"
				5:
					$Feedback/FeedbackText.text = "[center]Too easy. Knew it instantly in detail without looking at choices.[/center]"
			
func update_cursor_draw_location():	
	var question_offset = Vector2(-20, 25)
	var feedback_offset = Vector2(-20, 25)	
	
	if quiz_step == "prompt":
		$Cursor.visible = false
	
	if quiz_step == "choices":
		$Cursor.visible = true
		match cursorIndex:
			0:
				$Cursor.position = $Answers/Answer0.position + question_offset
			1:
				$Cursor.position = $Answers/Answer1.position + question_offset
			2:
				$Cursor.position = $Answers/Answer2.position + question_offset
			3: 
				$Cursor.position = $Answers/Answer3.position + question_offset
				
	elif quiz_step == "feedback":
		$Cursor.visible = true
		match cursorIndex:
			0:
				$Cursor.position = $Feedback/Feedback0.global_position + feedback_offset
			1:
				$Cursor.position = $Feedback/Feedback1.global_position + feedback_offset
			2:
				$Cursor.position = $Feedback/Feedback2.global_position + feedback_offset
			3: 
				$Cursor.position = $Feedback/Feedback3.global_position + feedback_offset
			4:
				$Cursor.position = $Feedback/Feedback4.global_position + feedback_offset
			5: 
				$Cursor.position = $Feedback/Feedback5.global_position + feedback_offset

func _input(event):
	if visible and quiz_step == "prompt":
		if event.is_action_pressed("ui_accept"):
			$"../CursorChoices".play()
			quiz_step = "choices"
	
	elif visible and quiz_step == "choices":		
		#if true or false we don't want to move up or down
		if CardDict.all_cards[card_number].question_type == "multiple choice":
			if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
				$"../CursorSound".play()
				match cursorIndex:
					0:
						cursorIndex = 2
					1:
						cursorIndex = 3
					2:
						cursorIndex = 0
					3: 
						cursorIndex = 1
						
		if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right") :
			$"../CursorSound".play()
			match cursorIndex:
				0:
					cursorIndex = 1
				1:
					cursorIndex = 0
				2:
					cursorIndex = 3
				3: 
					cursorIndex = 2
					
		if event.is_action_pressed("ui_accept"):
			quiz_step = "feedback"
			if cursorIndex == CardDict.all_cards[card_number].correct_index:
				#quizStatus = "correct"
				$"../CursorRight".play()
				got_question_correct = true
				#set_flag("correct_answer") #yes answer_was_correct
				cursorIndex = 3
			else:
				#quizStatus = "incorrect"
				$"../CursorWrong".play()
				got_question_correct = false
				#clear_flag("correct_answer") #not answer_was_correct
				cursorIndex = 0
					
	elif visible and quiz_step == "feedback":	
		
		if got_question_correct == true:
			if event.is_action_pressed("ui_left"):
				$"../CursorSound".play()
				
				if cursorIndex <= 0:
					cursorIndex = 5
				else:
					cursorIndex -= 1
				
			if event.is_action_pressed("ui_right"):
				$"../CursorSound".play()
				if cursorIndex >= 5:
					cursorIndex = 0
				else:
					cursorIndex += 1
					
		
		elif got_question_correct == false:
			if event.is_action_pressed("ui_left"):
				$"../CursorWrong".play()
				
			if event.is_action_pressed("ui_right"):
				$"../CursorWrong".play()
		
		if event.is_action_pressed("ui_accept"):
			$"../CursorFeedback".play()
			quiz_step = "prompt"
			card_number += 1
			cursorIndex = 0		

func color_answers_appropriately():
	var wrong_color = "[color=White]"
	var right_color = "[color=White]"
	if quiz_step == "feedback":
		wrong_color = "[color=Lightcoral]"
		right_color = "[color=Palegreen]"
	
	$Answers/Answer0.text = wrong_color + CardDict.all_cards[card_number].answer_list[0] + "[/color]"
	$Answers/Answer1.text = wrong_color + CardDict.all_cards[card_number].answer_list[1] + "[/color]"
	#if true or false we don't have answers 2 or 3
	if CardDict.all_cards[card_number].question_type == "multiple choice":
		$Answers/Answer2.text = wrong_color + CardDict.all_cards[card_number].answer_list[2] + "[/color]"
		$Answers/Answer3.text = wrong_color + CardDict.all_cards[card_number].answer_list[3] + "[/color]"
	elif CardDict.all_cards[card_number].question_type == "true or false":
		$Answers/Answer2.text = ""
		$Answers/Answer3.text = ""
	
	match CardDict.all_cards[card_number].correct_index:
		0: 
			$Answers/Answer0.text = right_color + CardDict.all_cards[card_number].answer_list[0] + "[/color]"
		1: 
			$Answers/Answer1.text = right_color + CardDict.all_cards[card_number].answer_list[1] + "[/color]"
		2: 
			$Answers/Answer2.text = right_color + CardDict.all_cards[card_number].answer_list[2] + "[/color]"
		3: 
			$Answers/Answer3.text = right_color + CardDict.all_cards[card_number].answer_list[3] + "[/color]"

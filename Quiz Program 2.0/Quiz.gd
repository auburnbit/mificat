extends Control

var card_number = 0
var dict = CardDict.dict
var cursorIndex = 0
var quiz_step = "prequiz"
var got_question_correct = false
var percent_needed = 1.0
var correct_number = 0
var success = false
var punishment = "No EXP nor Gil will be received from this battle!"

func _ready():
		#must do this or window can't be transparent
	get_tree().get_root().set_transparent_background(true)
	

func _process(delta):
	if visible:
		
		if quiz_step == "prequiz":
			$Music.stop()
		else:
			if $Music.playing != true:
				$Music.play()
		
		if float(correct_number) / float(CardDict.quiz_cards.size()) >= percent_needed:
			success = true
		else:
			success = false
		
		update_cursor_draw_location()	
	
		var card = CardDict.quiz_cards[card_number]
		$Prompt/PromptLabel/CategoryText.text = "Category: " + str(card.category)
		$Prompt/PromptLabel/QuestionNumber.text = "Question " + str(card_number + 1) + " of " + str(CardDict.quiz_cards.size())
		$Prompt/PromptLabel/ScoreNeeded.text = "Score Needed: " + str(int(percent_needed * 100)) + "%"
		color_answers_appropriately()
		if card.image == "none":		
			$Prompt/PromptLabel/PromptText.text = card.prompt
			$Prompt/PromptLabel/ImagePrompt.texture = load("res://card_images/no_image.jpg")
			$Prompt/PromptLabel/ImagePromptText.text = ""			
			$Prompt/PromptLabel/PromptText.visible = true
			$Prompt/PromptLabel/ImagePrompt.visible = false
			$Prompt/PromptLabel/ImagePromptText.visible = false
		else: 
			$Prompt/PromptLabel/PromptText.text = ""
			$Prompt/PromptLabel/ImagePrompt.texture = load("res://card_images/" + card.image)
			$Prompt/PromptLabel/ImagePromptText.text = card.prompt			
			$Prompt/PromptLabel/PromptText.visible = false
			$Prompt/PromptLabel/ImagePrompt.visible = true
			$Prompt/PromptLabel/ImagePromptText.visible = true	
			
		# perhaps make this: show_feedback()
		
		if quiz_step == "prequiz":
			$Prequiz.visible = true
			$Prompt.visible = false
			$Choices.visible = false
			$Feedback.visible = false
			$Results.visible = false
					
		elif quiz_step == "prompt":
			$Prequiz.visible = false
			$Prompt.visible = true
			$Choices.visible = false
			$Feedback.visible = false
			$Results.visible = false
			
		elif quiz_step == "choices":
			$Prequiz.visible = false
			$Prompt.visible = true
			$Choices.visible = true
			$Feedback.visible = false
			$Results.visible = false
		
		elif quiz_step == "feedback":
			$Prequiz.visible = false
			$Prompt.visible = true
			$Choices.visible = true
			$Feedback.visible = true
			$Results.visible = false
			
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
			
		elif quiz_step == "results":
			$Prequiz.visible = false
			$Prompt.visible = false
			$Choices.visible = false
			$Feedback.visible = false
			$Results.visible = true
			
			
			
func update_cursor_draw_location():	
	var question_offset = Vector2(-20, 25)
	var feedback_offset = Vector2(-20, 25)	
	
	if quiz_step == "prequiz":
		$Cursor.visible = false
	
	if quiz_step == "prompt":
		$Cursor.visible = false
	
	elif quiz_step == "choices":
		$Cursor.visible = true
		match cursorIndex:
			0:
				$Cursor.global_position = $Choices/Answer0.global_position + question_offset
			1:
				$Cursor.global_position = $Choices/Answer1.global_position + question_offset
			2:
				$Cursor.global_position = $Choices/Answer2.global_position + question_offset
			3: 
				$Cursor.global_position = $Choices/Answer3.global_position + question_offset
				
	elif quiz_step == "feedback":
		$Cursor.visible = true
		match cursorIndex:
			0:
				$Cursor.global_position = $Feedback/Feedback0.global_position + feedback_offset
			1:
				$Cursor.global_position = $Feedback/Feedback1.global_position + feedback_offset
			2:
				$Cursor.global_position = $Feedback/Feedback2.global_position + feedback_offset
			3: 
				$Cursor.global_position = $Feedback/Feedback3.global_position + feedback_offset
			4:
				$Cursor.global_position = $Feedback/Feedback4.global_position + feedback_offset
			5: 
				$Cursor.global_position = $Feedback/Feedback5.global_position + feedback_offset
	elif quiz_step == "results":
		$Cursor.visible = false
		var cn = float(correct_number)
		var tn = float(CardDict.quiz_cards.size())
		if success == true:
			$Results/NumberCorrect.text = "[center][color=green]" + str(correct_number) + " out of " + str(CardDict.quiz_cards.size()) + " correct[/color][/center]"
			$Results/PercentCorrect.text = "[center][color=green]" + str(int(cn/tn*100)) + "% correct, " + str(percent_needed * 100) + "% needed[/color][/center]"
			$Results/SuccessText.text = "[center][color=green]Success![/color][/center]"
			$Results/PunishmentText.text = ""
		else:
			$Results/NumberCorrect.text = "[center][color=red]" + str(correct_number) + " out of " + str(CardDict.quiz_cards.size()) + " correct[/color]"
			$Results/PercentCorrect.text = "[center][color=red]" + str(int(cn/tn*100)) + "% correct, " + str(percent_needed * 100) + "% needed[/color][/center]"
			$Results/SuccessText.text = "[center][color=red]IDIOT![/color][/center]"
			$Results/PunishmentText.text = "[center][color=red]" + punishment + "[/color][/center]"		

func _input(event):
	if visible and quiz_step == "prompt":
		if event.is_action_pressed("ui_accept"):
			$CursorChoices.play()
			quiz_step = "choices"
	
	elif visible and quiz_step == "choices":		
		#if true or false we don't want to move up or down
		if CardDict.quiz_cards[card_number].question_type == "multiple choice":
			if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
				$CursorSound.play()
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
			$CursorSound.play()
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
			if cursorIndex == CardDict.quiz_cards[card_number].correct_index:
				#quizStatus = "correct"
				$CursorRight.play()
				got_question_correct = true
				correct_number += 1
				
				#set_flag("correct_answer") #yes answer_was_correct
				cursorIndex = 3
			else:
				#quizStatus = "incorrect"
				$CursorWrong.play()
				got_question_correct = false
				#clear_flag("correct_answer") #not answer_was_correct
				cursorIndex = 0
					
	elif visible and quiz_step == "feedback":	
		
		if got_question_correct == true:
			if event.is_action_pressed("ui_left"):
				$CursorSound.play()
				
				if cursorIndex <= 0:
					cursorIndex = 5
				else:
					cursorIndex -= 1
				
			if event.is_action_pressed("ui_right"):
				$CursorSound.play()
				if cursorIndex >= 5:
					cursorIndex = 0
				else:
					cursorIndex += 1
					
		
		elif got_question_correct == false:
			if event.is_action_pressed("ui_left"):
				$CursorWrong.play()
				
			if event.is_action_pressed("ui_right"):
				$CursorWrong.play()
		
		if event.is_action_pressed("ui_accept"):
			quiz_step = "prompt"
			if card_number < CardDict.quiz_cards.size() - 1:
				$CursorFeedback.play()
				CardDict.quiz_cards[card_number].update_card_location_and_dictionary_entry(cursorIndex)
				card_number += 1
			else:
				quiz_step = "results"
				if success == true:
					$Success.play()
				else:
					$Failure.play()
			cursorIndex = 0		
			
	elif visible and quiz_step == "results":
		if event.is_action_pressed("ui_accept"):
			$CursorFeedback.play()
			quiz_step = "prequiz"

func color_answers_appropriately():
	var wrong_color = "[color=White]"
	var right_color = "[color=White]"
	if quiz_step == "feedback":
		wrong_color = "[color=Lightcoral]"
		right_color = "[color=Palegreen]"
	
	$Choices/Answer0.text = "[center]" + wrong_color + CardDict.quiz_cards[card_number].answer_list[0] + "[/color][/center]"
	$Choices/Answer1.text = "[center]" + wrong_color + CardDict.quiz_cards[card_number].answer_list[1] + "[/color][/center]"
	#if true or false we don't have answers 2 or 3
	if CardDict.quiz_cards[card_number].question_type == "multiple choice":
		$Choices/Answer2.text = "[center]" + wrong_color + CardDict.quiz_cards[card_number].answer_list[2] + "[/color][/center]"
		$Choices/Answer3.text = "[center]" + wrong_color + CardDict.quiz_cards[card_number].answer_list[3] + "[/color][/center]"
	elif CardDict.quiz_cards[card_number].question_type == "true or false":
		$Choices/Answer2.text = ""
		$Choices/Answer3.text = ""
	
	match CardDict.quiz_cards[card_number].correct_index:
		0: 
			$Choices/Answer0.text = "[center]" + right_color + CardDict.quiz_cards[card_number].answer_list[0] + "[/color][/center]"
		1: 
			$Choices/Answer1.text = "[center]" + right_color + CardDict.quiz_cards[card_number].answer_list[1] + "[/color][/center]"
		2: 
			$Choices/Answer2.text = "[center]" + right_color + CardDict.quiz_cards[card_number].answer_list[2] + "[/color][/center]"
		3: 
			$Choices/Answer3.text = "[center]" + right_color + CardDict.quiz_cards[card_number].answer_list[3] + "[/color][/center]"


func _on_start_quiz_button_button_down():
	card_number = 0
	correct_number = 0
	quiz_step = "prompt"
	CardDict.grab_random_cards_from_churn(5)

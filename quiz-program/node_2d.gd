extends Control

const FLAG_31 = 0b10000000000000000000000000000000
const FLAG_30 = 0b01000000000000000000000000000000
const FLAG_29 = 0b00100000000000000000000000000000
const FLAG_28 = 0b00010000000000000000000000000000
const FLAG_27 = 0b00001000000000000000000000000000
const FLAG_26 = 0b00000100000000000000000000000000
const FLAG_25 = 0b00000010000000000000000000000000
const FLAG_24 = 0b00000001000000000000000000000000
var externalFlags = 0x00845FED
var Quiz
var Background
var Primary
var QuestionNumber
var QuizTimer
var Prompt
var Answer0
var Answer1
var Answer2
var Answer3
var Needed
var CostOfFailure
var Cursor
var DebugHelper
var DebugHelperInfo
var ToggleFlag29
var CursorSound
var CursorWrong
var PositiveOutcome
var KefkaLaugh
var Music
var cursorIndex = 0
var correctIndex = 3
var quizStatus = "quizzing"
var qNum = 0
var finalSoundHasPlayed = false
var showingResults = false
var questions = [[], [], [], [], [], [], [], [], [], []]
var	qn = "Question Number 1 of "
var	qt = "[right]Question Timer: [/right]"
var	cof = "[center]COST OF FAILURE: NO EXP OR GIL RECEIVED FROM THIS BATTLE[/center]"
var timer = 15
var endDelay = 1
var quiz_list_populated = false
var question_dic = {}
var number_questions_this_quiz = 1

func _ready():
	
	link_scene_nodes()
	
	#must do this or window can't be transparent
	get_tree().get_root().set_transparent_background(true)

func _process(delta):
	
	#cleanup:why just this one here?
	CostOfFailure.text = cof	
	
	if quiz_list_populated == false:	
		populate_quiz_list()
	
	if on_last_question() and endDelay <= 0 and !showingResults:		
		show_and_handle_results()		
		
	if endDelay <= 0:			
		reset_for_next_question_or_quiz()
	
	update_external_communication_flags_and_debug_helper()
	
	update_cursor_draw_location()	
	
	if !showingResults and quizStatus == "quizzing" and questions != [[], [], [], [], [], [], [], [], [], []]:
		update_labels()	
		
		if timer > 0 and quizStatus == "quizzing":
			if Music.playing == false:
				Music.playing = true
			Primary.visible = true
			timer -= delta
			if timer <= 0:
				handle_time_up()

func number_of_correct_answers():
	var sum = 0	
	for n in number_questions_this_quiz:
		if questions[n][5] == "correct":
			sum += 1
	return sum	

func percent_correct_int():
	return int(float(number_of_correct_answers()) / float(number_questions_this_quiz) * 100)

func _input(event):
	
	if endDelay > 0 and (quizStatus == "correct" or quizStatus == "incorrect"):
		if event.is_action_pressed("ui_accept"):
			endDelay = 0
	
	if quizStatus == "quizzing" and !showingResults:
		if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down")):
			CursorSound.play()
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
			CursorSound.play()
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
			color_answers_appropriately()
			if cursorIndex == correctIndex:
				quizStatus = "correct"
				CursorSound.play()
				cof = "[center][color=green]CORRECT![/color][/center]"
				set_flag("correct_answer") #yes answer_was_correct
				
			else:
				quizStatus = "incorrect"
				CursorWrong.play()
				#KefkaLaugh.play() #probably just do this at end
				cof = "[center][color=red]INCORRECT![/color][/center]"
				clear_flag("correct_answer") #not answer_was_correct

func link_scene_nodes():
	Quiz = $Quiz		
	Primary = $Quiz/Primary
	Background = $Quiz/Primary/Background
	QuestionNumber = $Quiz/Primary/QuestionNumber
	QuizTimer = $Quiz/Primary/QuizTimer
	Prompt = $Quiz/Primary/Prompt
	Answer0 = $Quiz/Primary/Answer0
	Answer1 = $Quiz/Primary/Answer1
	Answer2 = $Quiz/Primary/Answer2
	Answer3 = $Quiz/Primary/Answer3
	Needed = $Quiz/Primary/Needed
	CostOfFailure = $Quiz/Primary/CostOfFailure
	Cursor = $Quiz/Primary/Cursor	
	DebugHelper = $Quiz/DebugHelper
	DebugHelperInfo = $Quiz/DebugHelper/DebugHelperInfo
	ToggleFlag29 = $Quiz/DebugHelper/ToggleFlag29	
	CursorSound = $CursorSound
	CursorWrong = $CursorWrong		
	PositiveOutcome = $PositiveOutcome
	KefkaLaugh = $KefkaLaugh	
	Music = $Music				

func update_external_communication_flags_and_debug_helper():
	var flag31 = (externalFlags & FLAG_31) >> 31
	var flag30 = (externalFlags & FLAG_30) >> 30
	var flag29 = (externalFlags & FLAG_29) >> 29
	var flag28 = (externalFlags & FLAG_28) >> 28
	var flag27 = (externalFlags & FLAG_27) >> 27
	var flag26 = (externalFlags & FLAG_26) >> 26
	var flag25 = (externalFlags & FLAG_25) >> 25
	var flag24 = (externalFlags & FLAG_24) >> 24

	var debugHelperInfoFormatString = "External Communication Flags  (First byte of value 0x%08X)"+\
									"\n (31) (CAN'T WRITE TO?):  %d        (30) CORRECT_ANSWER:     %d" +\
									"\n (29) CURRENTLY_QUIZZING: %d        (28) UNUSED:             %d" +\
									"\n (27) UNUSED:             %d        (26) UNUSED:             %d" +\
									"\n (25) UNUSED:             %d        (24) UNUSED:             %d"
	DebugHelperInfo.text = debugHelperInfoFormatString % [externalFlags, \
	flag31, flag30, flag29, flag28, flag27, flag26, flag25, flag24]
		
	if flag_is_set("currently_quizzing"):
		ToggleFlag29.button_pressed = true
	else:
		ToggleFlag29.button_pressed = false
	
	if flag29 == 1 and quizStatus == "not quizzing":
		quizStatus = "quizzing"		
	
	if flag29 == 0:
		quizStatus = "not quizzing"

func populate_quiz_list():
	number_questions_this_quiz = randi_range(2,3)
	var qp_copy = [] + QuizDict.question_pool
	for i in number_questions_this_quiz:
		var qp_random_index = randi_range(0,QuizDict.pool_size-1-i)
		questions[i].append(qp_copy[qp_random_index].definition)
		questions[i].append(qp_copy[qp_random_index].answers[0])
		questions[i].append(qp_copy[qp_random_index].answers[1])
		questions[i].append(qp_copy[qp_random_index].answers[2])
		questions[i].append(qp_copy[qp_random_index].answers[3])
		questions[i].append("waiting for input")
		questions[i].append(qp_copy[qp_random_index].correct_answer_index)
		qp_copy.pop_at(qp_random_index)
	quiz_list_populated = true

func show_and_handle_results():
	questions[qNum][5] = quizStatus #storing result of question 
	showingResults = true
	Cursor.visible = false
	endDelay = 4
				
	if percent_correct_int() < 100: #TODO: this 100 needs to be a variable
		Prompt.text = "[color=red][center]\n\n\nNumber correct answers: "\
		+ str(number_of_correct_answers()) + " of " + str(number_questions_this_quiz)\
		+ "\n\n Percent correct: " + str(percent_correct_int()) + "%[/center][/color]"
		Needed.text = "[center][color=red]Score Needed: 100%[/color][/center]"
		#TODO: THIS 100% ALSO NEEDS variable
		cof = "[center][color=red]FAILURE! NO EXP OR GIL RECEIVED FROM THIS BATTLE!"
		quizStatus = "incorrect"
		clear_flag("correct_answer")
		if !finalSoundHasPlayed:
			KefkaLaugh.play()
			finalSoundHasPlayed = true				
	else:
		Prompt.text = "[color=green][center]\n\n\nNumber of correct answers: "\
		+ str(number_of_correct_answers()) + " of " + str(number_questions_this_quiz)\
		+ "\n\n Percent correct: " + str(percent_correct_int()) + "%[/center][/color]"
		Needed.text = "[center][color=green]Score Needed: 100%[/color][/center]"
		cof = "[center][color=green]SUCCESS!!"
		quizStatus = "correct"
		set_flag("correct_answer")
		if !finalSoundHasPlayed:
			PositiveOutcome.play()
			finalSoundHasPlayed = true
		#TODO: THIS 100% ALSO NEEDS variable
	QuestionNumber.text = ""
	QuizTimer.text = ""
	Answer0.text = ""
	Answer1.text = ""
	Answer2.text = ""
	Answer3.text = ""

func reset_for_next_question_or_quiz():	
	timer = 15 #MAGIC NUMBER	
	endDelay = 1 #MAGIC NUMBER + UNUSED NOW
	cursorIndex = 0
	questions[qNum][5] = quizStatus #storing result of question 
	cof = "[center]COST OF FAILURE: NO EXP OR GIL RECEIVED FROM THIS BATTLE[/center]"
	if !showingResults:
		qNum += 1
		endDelay = 1
		quizStatus = "quizzing"
		
	else:
			#Close and reset for next round
			reshuffleWrongAnswers()
			quizStatus = "not quizzing" #redudant with flag clearing too	
			questions.clear()
			questions = [[], [], [], [], [], [], [], [], [], []]
			quiz_list_populated = false			
			Primary.visible = false
			Music.playing = false
			qNum = 0
			finalSoundHasPlayed = false
			showingResults = false
			Cursor.visible = true
			Needed.text = "[center]Score Needed: 100%[/center]" 
			clear_flag("currently_quizzing")

func update_cursor_draw_location():	
	match cursorIndex:
		0:
			Cursor.position = Answer0.position + Vector2(-9, 6.5)
		1:
			Cursor.position = Answer1.position + Vector2(-9, 6.5)
		2:
			Cursor.position = Answer2.position + Vector2(-9, 6.5)
		3: 
			Cursor.position = Answer3.position + Vector2(-9, 6.5)

func update_labels():
	QuestionNumber.text = "Question " + str(qNum + 1) \
	+ " of " + str(number_questions_this_quiz)
	QuizTimer.text = qt + str(int(timer)+1)
	Prompt.text = questions[qNum][0]
	Answer0.text = questions[qNum][1]
	Answer1.text = questions[qNum][2]
	Answer2.text = questions[qNum][3]
	Answer3.text = "[HIDDEN]"
	correctIndex = questions[qNum][6]
	CostOfFailure.text = cof

func handle_time_up():
	QuizTimer.text = "0"
	timer = -1
	quizStatus = "incorrect"
	cof = "[center][color=red]TIME UP!"
	CursorWrong.play()
	clear_flag("correct_answer")
	color_answers_appropriately()

func _on_toggle_flag_29_toggled(button_pressed):
	if ToggleFlag29.button_pressed:
		set_flag("currently_quizzing") #yes quizzing_now
	else:
		clear_flag("currently_quizzing") #not quizzing_now

func set_flag_by_bit(bit_number):
	match bit_number:
		29:
			externalFlags |= 0b00100000000000000000000000000000
		30:
			externalFlags |= 0b01000000000000000000000000000000

func clear_flag_by_bit(bit_number):
	match bit_number:
		29:
			externalFlags &= ~0b00100000000000000000000000000000
		30:
			externalFlags &= ~0b01000000000000000000000000000000

func set_flag(flag_name):
	match flag_name:
		"currently_quizzing":
			set_flag_by_bit(29)
		"correct_answer":
			set_flag_by_bit(30)

func clear_flag(flag_name):
	match flag_name:
		"currently_quizzing":
			clear_flag_by_bit(29)
		"correct_answer":
			clear_flag_by_bit(30)

func flag_is_set_by_bit(bit_number):
	match bit_number:
		29:
			if (externalFlags & FLAG_29) >> 29 == 1:
				return true
			else:
				return false
		30:
			if (externalFlags & FLAG_30) >> 30 == 1:
				return true
			else:
				return false

func flag_is_set(flag_name):
		match flag_name:
			"currently_quizzing":
				return flag_is_set_by_bit(29)
			"correct_answer":
				return flag_is_set_by_bit(30)

func on_last_question():
	if qNum >= number_questions_this_quiz - 1:
		return true
	else:
		return false

func past_last_question():
	if qNum >= questions.size():
		return true
	else:
		return false

func reshuffleWrongAnswers():
	
	for i in QuizDict.pool_size:
		#TODO: WARN IF POOL SIZE IS GREATER THAN ALL TERMS SIZE
		var old_q = QuizDict.question_pool[i]
		old_q.answers.clear()
		var siblings = []
		for key in QuizDict.quiz_dict.keys():
			if key != old_q.term:
				if old_q.category == QuizDict.quiz_dict.get(key).get("Category"):
					siblings.append(key)
		
		#all terms left will be needed if not enough siblings. Then just choose from all other terms
		var all_terms_left = [] + QuizDict.all_terms
		all_terms_left.erase(old_q.term)
		while old_q.answers.size() < 4:
			if siblings.size() != 0:
				var new_wrong_answer = siblings.pop_at(randi() % siblings.size())
				old_q.answers.append(new_wrong_answer)
				all_terms_left.erase(new_wrong_answer)
			else:
				var new_wrong_answer = all_terms_left.pop_at(randi() % all_terms_left.size())
				old_q.answers.append(new_wrong_answer)
		
		old_q.correct_answer_index = randi_range(0,3)
		old_q.answers[old_q.correct_answer_index] = old_q.term				
					
		#TODO: SOMETHING IS WRONG HERE, THEY'RE DOING THIS TWICE IN A ROW, SAME TERM
		print ("\nPool Question Updated:")
		old_q.print_term_and_definition()
		old_q.print_answer_selection()	
		#old q is reborn with new wrong answer

func color_answers_appropriately():
	Answer0.text = "[color=Lightcoral]" + questions[qNum][1] + "[/color]"
	Answer1.text = "[color=Lightcoral]" + questions[qNum][2] + "[/color]"
	Answer2.text = "[color=Lightcoral]" + questions[qNum][3] + "[/color]"
	Answer3.text = "[color=Lightcoral]" + questions[qNum][4] + "[/color]"
	match correctIndex:
		0: 
			Answer0.text = "[color=Palegreen]" + questions[qNum][1] + "[/color]"
		1: 
			Answer1.text = "[color=Palegreen]" + questions[qNum][2] + "[/color]"
		2: 
			Answer2.text = "[color=Palegreen]" + questions[qNum][3] + "[/color]"
		3: 
			Answer3.text = "[color=Palegreen]" + questions[qNum][4] + "[/color]"

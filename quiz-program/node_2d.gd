extends Node2D

#TODO: CHANGE "SCORE NEEDED" BACK TO OLD COLOR AFTER DONE

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

var q0 = ["This class describes a Bézier curve in 2D space. It is mainly used to give a shape to a \
Path2D, but can be manually sampled for other purposes.", "CollisionPolygon2D", \
"CanvasGroup", "Marker2D", "Node2D", "waiting for input", 0]
var q1 = ["prompt1", "answer1a", "answer1b", "answer1c", "answer1d", "waiting for input", 1]
var q2 = ["prompt2", "answer2a", "answer2b", "answer2c", "answer2d", "waiting for input", 2]
var q3 = ["prompt3", "answer3a", "answer3b", "answer3c", "answer3d", "waiting for input", 3]
var q4 = ["prompt4", "answer4a", "answer4b", "answer4c", "answer4d", "waiting for input", 0]

var questions = [q0, q1, q2, q3, q4]

var	qn = "Question Number 1 of "
var	qt = "[right]Question Timer: [/right]"
var	prom = "\n[center]Say something.[/center]"
var	a1 = "*Something?"
var	a2 = "*Something"
var	a3 = "*something."
var	a4 = "*No"
var	cof = "[center]COST OF FAILURE: NO EXP OR GIL RECEIVED FROM THIS BATTLE[/center]"

var timer = 15
var endDelay = 1


var question_dic = {}

# Called when the node enters the scene tree for the first time.
func _ready():
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
	get_tree().get_root().set_transparent_background(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if endDelay > 0 and (quizStatus == "correct" or quizStatus == "incorrect"):
		endDelay -= delta
			
		if on_last_question() and endDelay <= 0 and !showingResults:
			
			questions[qNum][5] = quizStatus #storing result of question 
			showingResults = true
			Cursor.visible = false
			endDelay = 4
			
			if percent_correct_int() < 100: #TODO: this 100 needs to be a variable
				Prompt.text = "[color=red][center]\n\n\nNumber of correct answers: "\
				+ str(number_of_correct_answers()) + " of " + str(questions.size())\
				+ "\n\n Percent correct: " + str(percent_correct_int()) + "%[/center][/color]"
				Needed.text = "[center][color=red]Score Needed: 100%[/color][/center]" 
				#TODO: THIS 100% ALSO NEEDS variable
				CostOfFailure.text = "[center][color=red]FAILURE! NO EXP GIL RECEIVED FROM THIS BATTLE!"
				quizStatus = "incorrect"
				clear_flag("correct_answer")
				if !finalSoundHasPlayed:
					KefkaLaugh.play()
					finalSoundHasPlayed = true				
			else:
				Prompt.text = "[color=green][center]\n\n\nNumber of correct answers: "\
				+ str(number_of_correct_answers()) + " of " + str(questions.size())\
				+ "\n\n Percent correct: " + str(percent_correct_int()) + "%[/center][/color]"
				Needed.text = "[center][color=green]Score Needed: 100%[/color][/center]"
				CostOfFailure.text = "[center][color=green]SUCCESS!!"
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
		
	if endDelay <= 0:			
		#Reset for next question \
		timer = 15
		endDelay = 1
		cursorIndex = 0
		questions[qNum][5] = quizStatus #storing result of question 
		cof = "[center]COST OF FAILURE: NO EXP OR GIL RECEIVED FROM THIS BATTLE[/center]"
		if !showingResults:
			qNum += 1
			endDelay = 1
			quizStatus = "quizzing"
			
		else:
				#Close and reset for next round
				quizStatus = "not quizzing" #redudant with flag clearing too				
				Primary.visible = false
				Music.playing = false
				qNum = 0
				finalSoundHasPlayed = false
				showingResults = false
				Cursor.visible = true
				clear_flag("currently_quizzing")
				
	
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
		
	match cursorIndex:
		0:
			Cursor.position = Answer0.position
		1:
			Cursor.position = Answer1.position
		2:
			Cursor.position = Answer2.position
		3: 
			Cursor.position = Answer3.position
	if !showingResults:
		var fourBytes = "0x%08x"
		QuestionNumber.text = "Question " + str(qNum + 1) \
		+ " of " + str(questions.size())
		QuizTimer.text = qt + str(int(timer)+1)
		Prompt.text = questions[qNum][0]
		Answer0.text = questions[qNum][1]
		Answer1.text = questions[qNum][2]
		Answer2.text = questions[qNum][3]
		Answer3.text = questions[qNum][4]
		correctIndex = questions[qNum][6]
		CostOfFailure.text = cof
		
		if timer > 0 and quizStatus == "quizzing":
			if Music.playing == false:
				Music.playing = true
			Primary.visible = true
			timer -= delta
			if timer <= 0:
				timer = -1
				quizStatus = "incorrect"
				cof = "[center][color=red]TIME UP!"
				CursorWrong.play()
				clear_flag("correct_answer")
		
	

			
func number_of_correct_answers():
	var sum = 0
	for n in questions.size():
		if questions[n][5] == "correct":
			sum += 1
	return sum	

func percent_correct_int():
	return int(float(number_of_correct_answers()) / float(questions.size()) * 100)
	
func _input(event):
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
	if qNum >= questions.size() - 1:
		return true
	else:
		return false
		
func past_last_question():
	if qNum >= questions.size():
		return true
	else:
		return false
		

	

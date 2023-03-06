extends Node

const FLAG_30 = 0b01000000000000000000000000000000
const FLAG_29 = 0b00100000000000000000000000000000

var flags = 0x00845FED

func set_flag_by_bit(bit_number):
	match bit_number:
		29:
			flags |= 0b00100000000000000000000000000000
		30:
			flags |= 0b01000000000000000000000000000000

func clear_flag_by_bit(bit_number):
	match bit_number:
		29:
			flags &= ~0b00100000000000000000000000000000
		30:
			flags &= ~0b01000000000000000000000000000000

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
			if (flags & FLAG_29) >> 29 == 1:
				return true
			else:
				return false
		30:
			if (flags & FLAG_30) >> 30 == 1:
				return true
			else:
				return false

func flag_is_set(flag_name):
		match flag_name:
			"currently_quizzing":
				return flag_is_set_by_bit(29)
			"correct_answer":
				return flag_is_set_by_bit(30)

extends Node

const ARROW = preload("res://assets/images/cursors/arrow.png")
const POINTING = preload("res://assets/images/cursors/pointing.png")

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED,
	END_GAME,
}

var current_state = GameState.MAIN_MENU


func set_arrow() -> void:
	Input.set_custom_mouse_cursor(ARROW, Input.CURSOR_ARROW)


func set_pointing() -> void:
	Input.set_custom_mouse_cursor(POINTING, Input.CURSOR_ARROW)


func to_snake_case(input_string: String) -> String:
	var snake_case_string = ""

	for i in range(input_string.length()):
		var current_char = input_string.substr(i, 1)
		if current_char >= "A" and current_char <= "Z":
			if i > 0:
				snake_case_string += "_"
			snake_case_string += current_char.to_lower()
		else:
			snake_case_string += current_char

	return snake_case_string


func access_variable_by_name(node: Node, variable_name: String, value):
	node.set(variable_name, value)

extends Node

const ARROW = preload("res://assets/images/cursors/arrow.png")
const POINTING = preload("res://assets/images/cursors/pointing.png")

func set_arrow() -> void:
	Input.set_custom_mouse_cursor(ARROW, Input.CURSOR_ARROW)

func set_pointing() -> void:
	Input.set_custom_mouse_cursor(POINTING, Input.CURSOR_ARROW)

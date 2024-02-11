class_name CursorComponent
extends Node

@export var arrow: Texture
@export var pointing: Texture

func _ready():
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(pointing, Input.CURSOR_POINTING_HAND)

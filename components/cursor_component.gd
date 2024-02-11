class_name CursorComponent
extends Node

@export var arrow: Texture
@export var pointing: Texture

func _ready():
	set_arrow()

func set_arrow() -> void:
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW)

func set_pointing() -> void:
	Input.set_custom_mouse_cursor(pointing, Input.CURSOR_ARROW)

class_name OptionsMenu
extends Control


@onready var back_button: Button = $MarginContainer/VBoxContainer/Back

signal exit_options_menu


func _ready() -> void:
	handle_connectiong_signals()
	set_process(false)


func _on_back_pressed() -> void:
	#exit_options_menu.emit()
	emit_signal("exit_options_menu")
	set_process(false)

func handle_connectiong_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)

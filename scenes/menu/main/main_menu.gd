class_name MainMenu
extends Control


@onready var play_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Play
@onready var options_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Options
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Quit

@onready var options_menu: OptionsMenu = $OptionsMenu

@onready var margin_container: MarginContainer = $MarginContainer

const GAME_PLAY: PackedScene = preload("res://scenes/game_play.tscn")


func _ready() -> void:
	handle_connectiong_signals()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_PLAY)


func _on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false


func handle_connectiong_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	options_menu.exit_options_menu.connect(_on_exit_options_menu)

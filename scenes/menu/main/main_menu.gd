extends Control


@onready var play_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Play
@onready var options_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Options
@onready var quit_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/Quit

const GAME_PLAY: PackedScene = preload("res://scenes/game_play.tscn")
#const OPTIONS_MENU: PackedScene = preload("res://scenes/menu/options/options_menu.tscn")


func _ready() -> void:
	handle_connectiong_signals()


func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(GAME_PLAY)


func _on_options_pressed() -> void:
	#get_tree().change_scene_to_packed(OPTIONS_MENU)
	print("オプションに移動")


func _on_quit_pressed() -> void:
	get_tree().quit()


func handle_connectiong_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

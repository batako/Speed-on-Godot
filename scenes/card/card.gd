extends Node2D

var is_face_up: bool = false
var suit: String
var value: int
var animated_sprite: AnimatedSprite2D
var script_path = get_script().resource_path

func _ready() -> void:
	animated_sprite = get_node("AnimatedSprite2D")
	assert(suit, str(script_path) + " の suit が設定されていません。")
	assert(value, str(script_path) + " の value が設定されていません。")
	assert(animated_sprite, str(script_path) + " の animated_sprite が設定されていません。")
	turnFaceUp()

func setup(_suit: String, _value: int) -> void:
	suit = _suit
	value = _value

func turnFaceUp() -> void:
	is_face_up = true
	set_animation_and_frame(suit, value)

func turnFaceDown() -> void:
	is_face_up = false
	set_animation_and_frame("back", 0)

func set_animation_and_frame(animation_name: String, frame_number: int) -> void:
	animated_sprite.animation = animation_name
	animated_sprite.frame = frame_number


extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_face_up: bool = false
var suit: String
var value: int

signal selected_card(suit: String, value: int)

func _ready() -> void:
	var script_path = get_script().resource_path
	assert(suit, str(script_path) + " の suit が設定されていません。")
	assert(value, str(script_path) + " の value が設定されていません。")
	
	connect("input_event", _on_input_event.bind())
	connect("mouse_entered", _on_mouse_entered.bind())
	connect("mouse_exited", _on_mouse_exited.bind())
	
	turnFaceUp()

func _on_mouse_entered() -> void:
	Global.set_pointing()

func _on_mouse_exited() -> void:
	Global.set_arrow()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			emit_signal("selected_card", suit, value)

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

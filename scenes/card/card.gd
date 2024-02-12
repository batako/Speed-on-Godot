extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

enum OwnerType { PLAYER, ENEMY, FIELD }

var owner_type: OwnerType
var is_face_up: bool = false
var suit: String
var value: int

signal selected_card(suit: String, value: int)
signal draw_player_card
signal draw_enemy_card


func _ready() -> void:
	var script_path = get_script().resource_path
	assert(owner_type >= 0, str(script_path) + " の owner_type が設定されていません。")
	assert(suit, str(script_path) + " の suit が設定されていません。")
	assert(value >= 0, str(script_path) + " の value が設定されていません。")
	
	connect("input_event", _on_input_event.bind())
	connect("mouse_entered", _on_mouse_entered.bind())
	connect("mouse_exited", _on_mouse_exited.bind())
	
	turnFaceUp()


func _on_mouse_entered() -> void:
	Global.set_pointing()


func _on_mouse_exited() -> void:
	Global.set_arrow()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if Global.current_state != Global.GameState.PLAYING:
		return
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if suit == "deck":
				emit_signal("draw_" + owner_type_to_string() + "_card")
			else:
				emit_signal("selected_card", self)


func owner_type_to_string() -> String:
	match owner_type:
		OwnerType.PLAYER:
			return "player"
		OwnerType.ENEMY:
			return "enemy"
		OwnerType.FIELD:
			return "field"
		_:
			push_error("Invalid owner type: " + str(owner_type))
			return "Invalid"


func setup(_owner_type: String, _suit: String, _value: int) -> void:
	match _owner_type:
		"player":
			owner_type = OwnerType.PLAYER
		"enemy":
			owner_type = OwnerType.ENEMY
		"field":
			owner_type = OwnerType.FIELD
		_:
			push_error("Invalid owner type: " + _owner_type)
	
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

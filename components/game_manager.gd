class_name GameManager
extends Node

@export var CardRootNode: Node
@export var CardScene: PackedScene

@export var PlayerDeckSlot: Node
@export var PlayerCardSlot1: Node
@export var PlayerCardSlot2: Node
@export var PlayerCardSlot3: Node
@export var PlayerCardSlot4: Node

@export var EnemyDeckSlot: Node
@export var EnemyCardSlot1: Node
@export var EnemyCardSlot2: Node
@export var EnemyCardSlot3: Node
@export var EnemyCardSlot4: Node

@export var LeadSlot1: Node
@export var LeadSlot2: Node

var player_card_deck: Array
var enemy_card_deck: Array

var lead_slot1: Dictionary = { "suit": null, "value": null }
var lead_slot2: Dictionary = { "suit": null, "value": null }

var allow_lead_card = false


func _ready() -> void:
	setup_deck()
	set_field_hand_slot()
	start_round()


func _draw_player_card() -> void:
	draw_card("player")


func _draw_enemy_card() -> void:
	draw_card("enemy")


func _selected_card(node: Area2D) -> void:
	if !allow_lead_card:
		print("カードを出せません。")
		return
	
	if node.owner_type != node.OwnerType.PLAYER:
		print("プレイヤーのカードではありません。")
		return
	
	if is_adjacent_value(lead_slot1.value, node.value):
		move_field_hand_to_lead(node, LeadSlot1)
	elif is_adjacent_value(lead_slot2.value, node.value):
		move_field_hand_to_lead(node, LeadSlot2)


func setup_deck() -> void:
	var deck: Array = create_shuffled_deck()
	var deck_half_size: int = deck.size() / 2
	var player_cards: Array = deck.slice(0, deck_half_size - 1, true)
	var enemy_cards: Array = deck.slice(deck_half_size, deck.size() - 1, true)

	player_card_deck = player_cards
	enemy_card_deck = enemy_cards
	
	add_card(PlayerDeckSlot, "player", "deck", 0)
	add_card(EnemyDeckSlot, "enemy", "deck", 1)


func create_shuffled_deck() -> Array:
	var suits = ["club", "diamond", "heart", "spade"]
	var cards = []
	
	for suit in suits:
		for value in range(1, 14):
			cards.append({"suit": suit, "value": value})
	
	cards.shuffle()
	
	return cards


func set_field_hand_slot() -> void:
	for i in range(4):
		draw_card("player")
		draw_card("enemy")


func start_round() -> void:
	allow_lead_card = true
	
	set_lead_card_from_draw("player", LeadSlot1)
	set_lead_card_from_draw("enemy", LeadSlot2)


func set_lead_card_from_draw(owner_type: String, slot: Node) -> void:
	var card_deck = get_card_deck(owner_type)
	
	if card_deck.size() > 0:
		var card = card_deck.pop_front()
		set_lead_card(slot, card.suit, card.value)
	else:
		push_error(owner_type + " の山札はありません。")


func set_lead_card(slot: Node, suit: String, value: int) -> void:
	add_card(slot, "field", suit, value)
	access_variable_by_name(
		to_snake_case(slot.name),
		{ "suit": suit, "value": value }
	)


func to_snake_case(input_string: String) -> String:
	var snake_case_string = ""

	for i in range(input_string.length()):
		var char = input_string.substr(i, 1)
		if char >= "A" and char <= "Z":
			if i > 0:
				snake_case_string += "_"
			snake_case_string += char.to_lower()
		else:
			snake_case_string += char

	return snake_case_string


func access_variable_by_name(variable_name: String, value):
	set(variable_name, value)


func add_card(root_node: Node, owner_type: String, suit: String, value: int) -> void:
	if owner_type != "player" and owner_type != "enemy" and owner_type != "field":
		push_error("不正な owner_type です。:  " + owner_type)
		return
	
	var card_instance: Area2D = CardScene.instantiate()
	card_instance.name = "%s_%d" % [suit.capitalize(), value]
	card_instance.setup(owner_type, suit, value)
	root_node.add_child(card_instance)

	match suit:
		"deck":
			if owner_type == "player":
				card_instance.connect("draw_player_card", _draw_player_card.bind())
			elif owner_type == "enemy":
				card_instance.connect("draw_enemy_card", _draw_enemy_card.bind())
			else:
				push_error("不正な owner_type です。:  " + owner_type)
		_:
			card_instance.connect("selected_card", _selected_card.bind())


func draw_card(owner_type: String) -> void:
	if owner_type != "player" and owner_type != "enemy":
		push_error("不正な owner_type です。:  " + owner_type)
		return
	
	var slot = get_empty_field_hand_slot(owner_type)
	if slot:
		var card = draw_card_from_deck(owner_type)
		if card.size() != 0:
			add_card(slot, owner_type, card.suit, card.value)
	else:
		push_error("空きスロットがないため引くことができません。")


func get_empty_field_hand_slot(owner_type: String) -> Node:
	var card_slots = get_field_hand_slots(owner_type)
	return find_first_empty_child_node(card_slots)


func get_field_hand_slots(owner_type: String) -> Array:
	match owner_type:
		"player":
			return [PlayerCardSlot1, PlayerCardSlot2, PlayerCardSlot3, PlayerCardSlot4]
		"enemy":
			return [EnemyCardSlot1, EnemyCardSlot2, EnemyCardSlot3, EnemyCardSlot4]
		_:
			push_error("不正な owner_type です。:  " + owner_type)
			return []


func find_first_empty_child_node(nodes: Array) -> Node:
	for node in nodes:
		if node.get_child_count() == 0:
			return node
	return null


func draw_card_from_deck(owner_type: String) -> Dictionary:
	var card_deck = get_card_deck(owner_type)
	
	if card_deck.size() > 0:
		return card_deck.pop_front()
	else:
		push_error(owner_type + " の山札はありません。")
		return {}


func get_card_deck(owner_type: String) -> Array:
	match owner_type:
		"player":
			return player_card_deck
		"enemy":
			return enemy_card_deck
		_:
			push_error("不正な owner_type です。:  " + owner_type)
			return []


func is_adjacent_value(lead_value: int, value_to_check: int) -> bool:
	if lead_value != null:
		if value_to_check == lead_value + 1 or value_to_check == lead_value - 1:
			return true
		elif (lead_value == 13 and value_to_check == 1) or (lead_value == 1 and value_to_check == 13):
			return true
		elif value_to_check == lead_value:
			return false
	
	return false


func move_field_hand_to_lead(node: Node, slot: Node) -> void:
	set_lead_card(slot, node.suit, node.value)
	node.queue_free()

extends Node

@export var CardRootNode: Node
@export var CardScene: PackedScene

@export var LeadSlot1: Node
@export var LeadSlot2: Node

@export var PlayerDeckSlot: Node
@export var PlayerFieldHandSlot1: Node
@export var PlayerFieldHandSlot2: Node
@export var PlayerFieldHandSlot3: Node
@export var PlayerFieldHandSlot4: Node

@export var EnemyDeckSlot: Node
@export var EnemyFieldHandSlot1: Node
@export var EnemyFieldHandSlot2: Node
@export var EnemyFieldHandSlot3: Node
@export var EnemyFieldHandSlot4: Node

@export var status_check_interval_seconds: float = 1

var player_card_deck: Array
var enemy_card_deck: Array

var lead_slot1: Dictionary = { "suit": null, "value": null }
var lead_slot2: Dictionary = { "suit": null, "value": null }

var card_slots: Array[Node] = []
var player_field_hand_slots: Array[Node] = []
var enemy_field_hand_slots: Array[Node] = []

var timer: float = 0

func _ready() -> void:
	reset()


func _process(delta: float) -> void:
	if Global.current_state != Global.GameState.PLAYING:
		timer = 0.0
		return

	timer += delta
	
	if timer >= status_check_interval_seconds:
		timer = 0.0
		
		if !check_available_actions_for_player_and_enemy():
			start_round()


func _draw_player_card() -> void:
	draw_card("player")


func _draw_enemy_card() -> void:
	draw_card("enemy")


func _selected_card(node: Area2D, is_cpu: bool = false) -> void:
	if !is_cpu and node.owner_type != node.OwnerType.PLAYER:
		print("プレイヤーのカードではありません。")
		return
	
	if !lead_slot1.value or is_adjacent_value(lead_slot1.value, node.value):
		move_field_hand_to_lead(node, LeadSlot1)
	elif !lead_slot2.value or is_adjacent_value(lead_slot2.value, node.value):
		move_field_hand_to_lead(node, LeadSlot2)

	check_victory_condition(node.owner_type_to_string())
	

func reset() -> void:
	initialize_variables()
	clear_card_slots()
	setup_deck()
	set_field_hand_slot()
	start_round()


func initialize_variables() -> void:
	player_field_hand_slots = [
		PlayerFieldHandSlot1,
		PlayerFieldHandSlot2,
		PlayerFieldHandSlot3,
		PlayerFieldHandSlot4,
	]
	enemy_field_hand_slots = [
		EnemyFieldHandSlot1,
		EnemyFieldHandSlot2,
		EnemyFieldHandSlot3,
		EnemyFieldHandSlot4,
	]
	card_slots = [
		LeadSlot1,
		LeadSlot2,
		PlayerDeckSlot,
		EnemyDeckSlot,
	]
	card_slots += player_field_hand_slots + enemy_field_hand_slots
	
	lead_slot1 = { "suit": null, "value": null }
	lead_slot2 = { "suit": null, "value": null }
	
	Global.current_state = Global.GameState.PLAYING


func clear_card_slots() -> void:
	for slot in card_slots:
		remove_all_children(slot)


func setup_deck() -> void:
	var deck: Array = create_shuffled_deck()
	var deck_half_size: int = int(deck.size() / 2.0)
	var player_cards: Array = deck.slice(0, deck_half_size - 1, true)
	var enemy_cards: Array = deck.slice(deck_half_size, deck.size(), true)

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
	set_lead_card_from_deck_or_field_hand("player", LeadSlot1)
	set_lead_card_from_deck_or_field_hand("enemy", LeadSlot2)


func set_lead_card_from_deck_or_field_hand(owner_type: String, slot: Node) -> void:
	var card_deck = get_card_deck(owner_type)
	
	if card_deck.size() > 0:
		var card = draw_card_from_deck(owner_type)
		set_lead_card(slot, card.suit, card.value)
	else:
		var card = get_card_from_any_field_hand(owner_type)
		if card:
			set_lead_card(slot, card.suit, card.value)
			card.queue_free()
		else:
			push_error(owner_type + " の山札と場札はありません。")

	check_victory_condition(owner_type)


func set_lead_card(slot: Node, suit: String, value: int) -> void:
	add_card(slot, "field", suit, value)
	Global.access_variable_by_name(
		self,
		Global.to_snake_case(slot.name),
		{ "suit": suit, "value": value }
	)


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


func get_card_from_any_field_hand(owner_type: String) -> Area2D:
	if owner_type != "player" and owner_type != "enemy":
		push_error("不正な owner_type です。:  " + owner_type)
		return
	
	var field_hand_slots = get_field_hand_slots(owner_type)
	return get_first_child_of_first_present_node(field_hand_slots)


func get_first_child_of_first_present_node(nodes: Array) -> Node:
	for node in nodes:
		if node.get_child_count() > 0:
			return node.get_child(0)
	return null


func check_available_actions_for_player_and_enemy() -> bool:
	var value = false
	var field_hand_slots = player_field_hand_slots + enemy_field_hand_slots
	
	for slot in field_hand_slots:
		if slot.get_child_count() == 0:
			continue

		var card = slot.get_child(0)
		if !lead_slot1.value or is_adjacent_value(lead_slot1.value, card.value):
			value = true
		elif !lead_slot2.value or is_adjacent_value(lead_slot2.value, card.value):
			value = true
	
	return value


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
	var field_hand_slots = get_field_hand_slots(owner_type)
	return get_first_empty_child_node(field_hand_slots)


func get_field_hand_slots(owner_type: String) -> Array[Node]:
	match owner_type:
		"player":
			return player_field_hand_slots
		"enemy":
			return enemy_field_hand_slots
		_:
			push_error("不正な owner_type です。:  " + owner_type)
			return []


func get_first_empty_child_node(nodes: Array) -> Node:
	for node in nodes:
		if node.get_child_count() == 0:
			return node
	return null


func draw_card_from_deck(owner_type: String) -> Dictionary:
	var card_deck = get_card_deck(owner_type)
	
	if card_deck.size() > 0:
		var card = card_deck.pop_front()
		clear_deck_slot_if_empty(owner_type)
		return card
	else:
		push_error(owner_type + " の山札はありません。")
		return {}


func clear_deck_slot_if_empty(owner_type: String) -> void:
	match owner_type:
		"player":
			if player_card_deck.size() == 0:
				remove_all_children(PlayerDeckSlot)
		"enemy":
			if enemy_card_deck.size() == 0:
				remove_all_children(EnemyDeckSlot)


func get_card_deck(owner_type: String) -> Array:
	match owner_type:
		"player":
			return player_card_deck
		"enemy":
			return enemy_card_deck
		_:
			push_error("不正な owner_type です。:  " + owner_type)
			return []


func is_adjacent_value(reference_value: int, comparison_value: int) -> bool:
	if comparison_value == reference_value + 1 or comparison_value == reference_value - 1:
		return true
	elif (reference_value == 13 and comparison_value == 1) or (reference_value == 1 and comparison_value == 13):
		return true
	elif comparison_value == reference_value:
		return false

	return false


func move_field_hand_to_lead(node: Node, slot: Node) -> void:
	remove_all_children(slot)
	set_lead_card(slot, node.suit, node.value)
	node.queue_free()


func remove_all_children(node: Node):
	for child in node.get_children():
		child.queue_free()


func check_victory_condition(owner_type: String) -> void:
	if Global.current_state != Global.GameState.PLAYING:
		return
	
	await get_tree().process_frame
	
	var user_slots = get_field_hand_slots(owner_type)
	var deck = get_card_deck(owner_type)

	if are_all_nodes_without_children(user_slots) and deck.size() == 0:
		Global.current_state = Global.GameState.END_GAME
		print(owner_type + " の勝利")


func are_all_nodes_without_children(nodes: Array) -> bool:
	for node in nodes:
		if node.get_child_count() > 0:
			return false
	return true

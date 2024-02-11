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

var player_card_deck: Array
var enemy_card_deck: Array


func _ready() -> void:
	setup_cards()


func _draw_player_card() -> void:
	draw_card("player")


func _draw_enemy_card() -> void:
	draw_card("enemy")


func _selected_card(suit: String, value: int) -> void:
	print("_selected_card")
	print(suit + " : " + str(value))


func setup_cards() -> void:
	setup_deck()

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


func setup_deck() -> void:
	var deck: Array = create_shuffled_deck()
	var deck_half_size: int = deck.size() / 2
	var player_cards: Array = deck.slice(0, deck_half_size - 1, true)
	var enemy_cards: Array = deck.slice(deck_half_size, deck.size() - 1, true)

	player_card_deck = player_cards
	enemy_card_deck = enemy_cards


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

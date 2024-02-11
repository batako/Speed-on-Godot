class_name GameManager
extends Node

@export var CardRootNode: Node
@export var card: PackedScene

func _ready() -> void:
	setup_cards()

func setup_cards() -> void:
	var suits = ["club", "diamond", "heart", "spade"]
	var cards = []
	
	for suit in suits:
		for value in range(1, 14):
			cards.append({"suit": suit, "value": value})
	
	cards.shuffle()
	
	for card in cards:
		add_card(card.suit, card.value)

func add_card(suit: String, value: int) -> void:
	var card_instance: Node2D = card.instantiate()
	card_instance.name = "%s_%d" % [suit.capitalize(), value]
	card_instance.position.x = 44
	card_instance.position.y = 62
	card_instance.setup(suit, value)
	CardRootNode.add_child(card_instance)

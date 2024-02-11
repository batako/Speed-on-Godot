class_name GameManager
extends Node

@export var CardRootNode: Node
@export var CardScene: PackedScene

var instance_cards: Array[Area2D] = []

func _ready() -> void:
	setup_cards()

func setup_cards() -> void:
	var suits = ["club", "diamond", "heart", "spade"]
	var cards = []
	
	for suit in suits:
		for value in range(1, 14):
			cards.append({"suit": suit, "value": value})
	
	cards.shuffle()
	
	var y = 0
	for card in cards:
		add_card(card.suit, card.value, y)
		y += 20

func add_card(suit: String, value: int, y: int) -> void:
	var card_instance: Area2D = CardScene.instantiate()
	card_instance.name = "%s_%d" % [suit.capitalize(), value]
	card_instance.position.x = 44 + y
	card_instance.position.y = 62
	card_instance.setup(suit, value)
	CardRootNode.add_child(card_instance)
	instance_cards.append(card_instance)
	card_instance.connect("selected_card", _selected_card.bind())

func _selected_card(suit: String, value: int) -> void:
	print("_selected_card")
	print(suit + " : " + str(value))

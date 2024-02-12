class_name CPUComponent
extends Node

@export var interval_seconds: float = 1

@export var GameManager: Node
@export var EnemyDeckSlot: Node
@export var EnemyFieldHandSlot1: Node
@export var EnemyFieldHandSlot2: Node
@export var EnemyFieldHandSlot3: Node
@export var EnemyFieldHandSlot4: Node
@export var LeadSlot1: Node
@export var LeadSlot2: Node

var timer: float = 0
var slots: Array[Node] = []

func _ready() -> void:
	slots = [
		EnemyFieldHandSlot1,
		EnemyFieldHandSlot2,
		EnemyFieldHandSlot3,
		EnemyFieldHandSlot4,
	]

func _process(delta: float) -> void:
	timer += delta
	
	if timer >= interval_seconds:
		_execute_function()
		timer = 0.0

func _execute_function() -> void:
	for slot in slots:
		var card = slot.get_child(0)
		if card:
			GameManager._selected_card(card, true)
		else:
			GameManager._draw_enemy_card()

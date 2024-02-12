class_name CPUComponent
extends Node

@export var GameManager: Node

@export var LeadSlot1: Node
@export var LeadSlot2: Node
@export var EnemyDeckSlot: Node
@export var EnemyFieldHandSlot1: Node
@export var EnemyFieldHandSlot2: Node
@export var EnemyFieldHandSlot3: Node
@export var EnemyFieldHandSlot4: Node

@export var interval_seconds: float = 3

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
	if Global.current_state != Global.GameState.PLAYING:
		timer = 0.0
		return
	
	timer += delta
	
	if timer >= interval_seconds:
		timer = 0.0
		action()


func action() -> void:
	for slot in slots:
		var card = slot.get_child(0) if slot.get_child_count() > 0 else null
		if card:
			GameManager._selected_card(card, true)
		elif GameManager.enemy_card_deck.size() > 0:
			GameManager._draw_enemy_card()

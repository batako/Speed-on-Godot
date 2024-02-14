extends Control

signal animation_finished

func _ready() -> void:
	visible = false
	$AnimationPlayer.connect("animation_finished", _on_animation_player_animation_finished.bind())


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	visible = false
	emit_signal("animation_finished")

func play() -> void:
	visible = true
	$AnimationPlayer.play("countdown")

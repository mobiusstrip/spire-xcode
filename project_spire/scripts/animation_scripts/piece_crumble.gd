extends Node2D

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_crumble):
	queue_free()
	$AnimationPlayer.play("RESET")

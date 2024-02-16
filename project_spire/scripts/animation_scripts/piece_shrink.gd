extends Node2D


func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_shrink):
	queue_free()
	$AnimationPlayer.play("RESET")

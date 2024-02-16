extends Node2D

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_halo_grow):
	queue_free()
	$AnimationPlayer.play("RESET")

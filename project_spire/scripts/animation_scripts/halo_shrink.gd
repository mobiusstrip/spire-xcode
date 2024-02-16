extends Node2D


func _ready():
	$AnimationPlayer.play("halo_shrink")


func _on_AnimationPlayer_animation_finished(_halo_shrink):
	queue_free()
	$AnimationPlayer.play("RESET")

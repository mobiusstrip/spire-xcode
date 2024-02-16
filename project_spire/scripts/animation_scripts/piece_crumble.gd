extends Node2D

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_crumble):
#	print("OBJECTIVE_ANIMATION_FINISHED")
	queue_free()
	$AnimationPlayer.play("RESET")

extends Node2D

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_donezo):
	$AnimationPlayer.play("RESET")
	queue_free()

func argument_placer(color):
	if color=="blue":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/blue_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/blue_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/blue_adjacent_bomb.png")
	if color=="green":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/green_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/green_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/green_adjacent_bomb.png")
	if color=="orange":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/orange_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/orange_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/orange_adjacent_bomb.png")
	if color=="pink":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/pink_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/pink_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/pink_adjacent_bomb.png")
	if color=="purple":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/purple_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/purple_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/purple_adjacent_bomb.png")
	if color=="yellow":
		$col.texture=load("res://Assets/artwork/animation/bomb_explode_textures/yellow_col.png")
		$row.texture=load("res://Assets/artwork/animation/bomb_explode_textures/yellow_col.png")
		$adj.texture=load("res://Assets/artwork/animation/bomb_explode_textures/yellow_adjacent_bomb.png")

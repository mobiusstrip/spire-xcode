extends Node2D

func _ready():
	pass

func _on_AnimationPlayer_animation_finished(_help):
	$AnimationPlayer.play("RESET")
	queue_free()

func argument_placer(color):
	if color=="blue":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_blue_bomb_spawn.png")
	if color=="green":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_green_bomb_spawn.png")
	if color=="orange":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_orange_bomb_spawn.png")
	if color=="pink":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_pink__bomb_spawn.png")
	if color=="purple":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_purple_bomb_spawn.png")
	if color=="yellow":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/alt/alt_yellow_bomb_spawn.png")
	if color=="color":
		$main.texture=load("res://Assets/artwork/animation/bomb_spawn_textures/color_bomb_spawn.png")

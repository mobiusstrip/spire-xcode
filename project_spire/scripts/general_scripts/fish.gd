extends Node2D  #Defines what class to extend with the current class.

@export var color:String
@export var column_texture:Texture2D
@export var row_texture:Texture2D
@export var adjacent_texture:Texture2D
@export var bright_adjacent_texture:Texture2D
@export var color_bomb_texture:Texture2D
@export var bright_texture:Texture2D
@export var piece_texture:Texture2D
@export var sinker_texture:Texture2D

var is_special=false
var is_row_bomb =false
var is_column_bomb =false
var is_adjacent_bomb =false
var is_color_bomb =false
var is_sinker=false
var is_pseudo_adjacent_bomb=false
var matched = false
var is_fish = true

func move(target):
	var tween=get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"position",target,0.3)

func make_column_bomb():
	is_column_bomb=true
	is_special=true
	$Sprite2D.texture=column_texture

func make_row_bomb():
	is_row_bomb=true
	is_special=true
	$Sprite2D.texture=row_texture

func make_adjacent_bomb():
	matched=false
	is_adjacent_bomb=true
	is_special=true
	$Sprite2D.texture=adjacent_texture

func make_color_bomb():
	is_color_bomb=true
	is_special=true
	$Sprite2D.texture=color_bomb_texture
	color='color'

func make_sinker():
	is_sinker=true
	is_special=true
	$Sprite2D.texture=sinker_texture
	color="sinker"

func make_pseudo_adjacent_bomb():
	is_adjacent_bomb=false
	is_pseudo_adjacent_bomb=true
	is_special=false
	matched=false
	$Sprite2D.texture=bright_adjacent_texture

func make_invisible():
	$Sprite2D.modulate=Color(1,1,1,0)

func _make_visible():
	$Sprite2D.modulate=Color(1,1,1,1)

#------------------------------------------
@onready var this_sprite=$Sprite2D

func wiggle(direction):
	var tween=get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	if direction=="up":
		this_sprite.texture=bright_texture
		tween.tween_property(this_sprite,"position",Vector2.UP*10,1).as_relative()
		tween.tween_property(
		this_sprite, "position",Vector2.DOWN*10,1).as_relative()
		await tween.finished

	if direction=="down":
		this_sprite.texture=bright_texture
		tween.tween_property(this_sprite, "position",Vector2.DOWN*10,1).as_relative()
		tween.tween_property(
		this_sprite, "position",Vector2.UP*10,1).as_relative()
		await tween.finished

	if direction=="left":
		this_sprite.texture=bright_texture
		tween.tween_property(this_sprite, "position",Vector2.LEFT*10,1).as_relative()
		tween.tween_property(this_sprite,"position",Vector2.RIGHT*10,1).as_relative()
		await tween.finished

	if direction=="right":
		this_sprite.texture=bright_texture
		tween.tween_property(this_sprite,"position",Vector2.RIGHT*10,1).as_relative()
		tween.tween_property(this_sprite, "position",Vector2.LEFT*10,1).as_relative()
		await tween.finished
	
	if is_special!=true:
		this_sprite.texture=piece_texture
	else:
		if is_column_bomb:
			this_sprite.texture=column_texture
		if is_row_bomb:
			this_sprite.texture=row_texture
		if is_adjacent_bomb:
			this_sprite.texture=adjacent_texture
		if is_color_bomb:
			this_sprite.texture=color_bomb_texture

#wiggles up down 
func wiggle2():
	var tween=get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	this_sprite.texture=bright_texture
	tween.tween_property(
	this_sprite, "position",Vector2.UP*10,1).as_relative()
	tween.tween_property(
	this_sprite, "position",Vector2.DOWN*10,1).as_relative()
	await tween.finished
	
	if is_special!=true:
		this_sprite.texture=piece_texture
	else:
		if is_column_bomb:
			this_sprite.texture=column_texture
		if is_row_bomb:
			this_sprite.texture=row_texture
		if is_adjacent_bomb:
			this_sprite.texture=adjacent_texture
		if is_color_bomb:
			this_sprite.texture=color_bomb_texture

func grow():
	$AnimationPlayer.play("grow")

func wiggle_for_adjacent(direction):
	var tween=get_tree().create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	if direction=="left":
		tween.tween_property(this_sprite, "position",Vector2.LEFT*10,1).as_relative()
		tween.tween_property(this_sprite, "position",Vector2.RIGHT*10,1).as_relative()

	if direction=="right":
		tween.tween_property(this_sprite, "position",Vector2.RIGHT*10,1).as_relative()
		tween.tween_property(this_sprite, "position",Vector2.LEFT*10,1).as_relative()

func _on_animation_player_animation_finished(_anim_name):
	$AnimationPlayer.play("RESET")
	queue_free()

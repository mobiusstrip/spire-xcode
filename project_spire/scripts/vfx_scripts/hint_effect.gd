extends Node2D

func _ready():
	setup(this_sprite.texture)

func setup(new_sprite):
	this_sprite.texture=new_sprite
	wiggle()

@onready var this_sprite=$Sprite2D

func wiggle():
	var tween=create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(this_sprite,"position",Vector2.LEFT*20,2).as_relative()


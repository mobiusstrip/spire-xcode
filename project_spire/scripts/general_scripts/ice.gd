extends Node2D

var health
@onready var this_sprite=$Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	if health==1:
		this_sprite.texture=health_1
	if health==2:
		this_sprite.texture=health_2
	if health==3:
		this_sprite.texture=health_3
	if health==4:
		this_sprite.texture=health_4
		

func text_setter():
	if health==1:
		this_sprite.texture=health_1
		this_sprite.modulate=Color(1,1,1,1)
	if health==2:
		this_sprite.texture=health_2
		this_sprite.modulate=Color(1,1,1,1)
	if health==3:
		this_sprite.texture=health_3
		this_sprite.modulate=Color(1,1,1,1)
	if health==4:
		this_sprite.texture=health_4
		this_sprite.modulate=Color(1,1,1,1)



func take_damage(damage):
	if health!=null:
		health -=damage
	#can add damage effect here
	
@export var health_1:Texture2D
@export var health_2:Texture2D
@export var health_3:Texture2D
@export var health_4:Texture2D

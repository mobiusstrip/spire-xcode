extends Path2D

signal walk_done
var current_point=0
var direction
@onready var walk_sprite=$walk
@onready var animation_player=get_parent().get_node("AnimationPlayer")
	

func _ready():
	position_updater()
	character_position()
	$walk.play("idle")

	
func position_updater():
	current_point=GameDataManager.level_info[0]["current_level"]-1
	#if level%2==0 
	if current_point==0:
		return
	if current_point%2==0:
		$walk.flip_h=true
	if current_point%2==1:
		$walk.flip_h=true
	
func character_position():
	#position
	walk_sprite.position=self.curve.get_point_position(current_point)+Vector2(+20,-38)

func _on_level_select_walk():
	var pos_old=self.curve.get_point_position(current_point)
	var pos_new=self.curve.get_point_position(current_point+1)
	animation_player.get_animation("walk").track_set_key_value(0,0,pos_old)
	animation_player.get_animation("walk").track_set_key_value(0,1,pos_new)
#	animation_player.play("walk")
#	$walk.play("walking")
#	SoundManager.play_fixed_sound("walk")
	current_point+=1
	character_position()

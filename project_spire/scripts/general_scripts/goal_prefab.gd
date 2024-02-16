extends TextureRect

var current_number=0
var max_value
var goal_texture
var goal_value
@onready var goal_label = $VBoxContainer/TextureRect/label
@onready var this_texture = $"."

func set_goal_values(new_max,new_texture,new_value):
	$".".texture=new_texture
	max_value=new_max
	goal_value=new_value
	current_number=max_value
	$VBoxContainer/TextureRect/label.text=""+str(max_value)

func update_goal_values(goal_type):
	if goal_type == goal_value :
		current_number-=1
		if current_number>=0:
			$VBoxContainer/TextureRect/label.text=""+str(current_number)

extends Node

func _ready():
	goal_texture_setter()

#Goal Info
var possible_goal_textures = [
	preload("res://Assets/artwork/goal_textures/regular/blue_goal.png"),#0
	preload("res://Assets/artwork/goal_textures/regular/green_goal.png"),#1
	preload("res://Assets/artwork/goal_textures/regular/orange_goal.png"),#2
	preload("res://Assets/artwork/goal_textures/regular/pink_goal.png"),#3
	preload("res://Assets/artwork/goal_textures/regular/purple_goal.png"),#4
	preload("res://Assets/artwork/goal_textures/regular/yellow_goal.png"),#5
	
	preload("res://Assets/artwork/goal_textures/obs/concrete.png"),#6
	preload("res://Assets/artwork/goal_textures/obs/ice.png"),#7
	preload("res://Assets/artwork/goal_textures/obs/lock.png"),#8
	preload("res://Assets/artwork/goal_textures/obs/marmalade.png"),#9
	preload("res://Assets/artwork/goal_textures/obs/sinker.png"),#10
	preload("res://Assets/artwork/goal_textures/general/colrow_goal.png"),#11
	
	preload("res://Assets/artwork/goal_textures/col/blue_column_goal.png"),#12
	preload("res://Assets/artwork/goal_textures/col/green_column_goal.png"),#13
	preload("res://Assets/artwork/goal_textures/col/orange_column_goal.png"),#14
	preload("res://Assets/artwork/goal_textures/col/pink_column_goal.png"),#15
	preload("res://Assets/artwork/goal_textures/col/purple_column_goal.png"),#16
	preload("res://Assets/artwork/goal_textures/col/yellow_column_goal.png"),#17
	
	preload("res://Assets/artwork/goal_textures/row/blue_row_goal.png"),#18
	preload("res://Assets/artwork/goal_textures/row/green_row_goal.png"),#19
	preload("res://Assets/artwork/goal_textures/row/orange_row_goal.png"),#20
	preload("res://Assets/artwork/goal_textures/row/pink_row_goal.png"),#21
	preload("res://Assets/artwork/goal_textures/row/purple_row_goal.png"),#22
	preload("res://Assets/artwork/goal_textures/row/yellow_row_goal.png"),#23
	
	preload("res://Assets/artwork/goal_textures/adj/blue_adjacent_goal.png"),#24
	preload("res://Assets/artwork/goal_textures/adj/green_adjacent_goal.png"),#25
	preload("res://Assets/artwork/goal_textures/adj/orange_adjacent_goal.png"),#26
	preload("res://Assets/artwork/goal_textures/adj/pink_adjacent_goal.png"),#27
	preload("res://Assets/artwork/goal_textures/adj/purple_adjacent_goal.png"),#28
	preload("res://Assets/artwork/goal_textures/adj/yellow_adjacent_goal.png"),#29
	
	preload("res://Assets/artwork/goal_textures/general/col_goal.png"),#30
	preload("res://Assets/artwork/goal_textures/general/row_goal.png"),#31
	preload("res://Assets/artwork/goal_textures/general/adj_goal.png"),#32
	
]
@export var max_needed: int
var goal_texture
@export var goal_string: String
var goal_met =false
var number_collected=0


func goal_texture_setter():
	match goal_string:
		"blue":
			goal_texture=possible_goal_textures[0]
		"green":
			goal_texture=possible_goal_textures[1]
		"orange":
			goal_texture=possible_goal_textures[2]
		"pink":
			goal_texture=possible_goal_textures[3]
		"purple":
			goal_texture=possible_goal_textures[4]
		"yellow":
			goal_texture=possible_goal_textures[5]
		"concrete":
			goal_texture=possible_goal_textures[6]
		"ice":
			goal_texture=possible_goal_textures[7]
		"lock":
			goal_texture=possible_goal_textures[8]
		"marmalade":
			goal_texture=possible_goal_textures[9]
		"sinker":
			goal_texture=possible_goal_textures[10]
		"striped":
			goal_texture=possible_goal_textures[11]
			
		"column":
			goal_texture=possible_goal_textures[30]
		"row":
			goal_texture=possible_goal_textures[31]
		"adjacent":
			goal_texture=possible_goal_textures[32]


func check_goal(goal_type):
	if goal_type ==goal_string:
		update_goal()

func update_goal():
	if number_collected<max_needed:
		number_collected+=1
	if number_collected==max_needed:
		if !goal_met :
			goal_met=true

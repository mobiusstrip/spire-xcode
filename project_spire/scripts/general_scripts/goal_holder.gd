extends Node

@export var score_goal_enabled:bool
signal create_goal
signal game_won
var score_met=false

func _ready():
	create_goals()

func create_goals():
	for i in get_child_count():
		var current=get_child(i)
		emit_signal("create_goal",current.max_needed,current.goal_texture,current.goal_string)

func check_goals(goal_type):
	for i in get_child_count():
		get_child(i).check_goal(goal_type)
	check_game_win()

func check_game_win():
	if score_goal_enabled:
		if goals_met() and score_met==true:
			emit_signal("game_won")
	else:
		if goals_met()==true:
			emit_signal("game_won")
	

func goals_met():
	for i in get_child_count():
		if !get_child(i).goal_met:
			return false
	return true

func _on_grid_check_goal(goal_type):
	check_goals(goal_type)

func _on_grid_break_lock(goal_type):
	check_goals(goal_type)

func _on_grid_break_ice(goal_type):
	check_goals(goal_type)

func _on_grid_break_concrete(goal_type):
	check_goals(goal_type)


func _on_grid_break_slime(goal_type):
	check_goals(goal_type)


func _on_score_goal_score_met():
	score_met=true


func _on_grid_break_marmalade(goal_type):
	check_goals(goal_type)

extends Node

func _ready():
	emit_signal("setup_score_needed",score_needed)

#score stuff
@export var score_needed: int
@export var max_score_star:int
signal setup_score_needed
var score
signal score_met

func is_score_met():
	if score==score_needed or score>score_needed:
		emit_signal("score_met")

func _on_grid_update_current_score(current_score):
	score=current_score
	is_score_met()

#1
extends Node2D

signal spawn_debug(i,j,color,type)

var x_starts=[470,412,355,297,240,182,125]
var y_starts=[1469,1536,1334,1671,1739,1806,1875]

var current_counter_value=15
var width=6
var height=6
var score_needed=300
var max_score_star=300
var score_goal_enabled=false
#obstacles spaces args are vec2s
var ice_spaces=[]
var ice_healths=[]
var lock_spaces=[]
var concrete_spaces=[]
var concrete_healths=[]
var slime_spaces=[]
var empty_spaces=[]
var marmalade_spaces=[]
var marmalade_healths=[]
var x_start = x_starts[width-3]
var y_start = y_starts[height-3]

func _ready():
	get_parent().get_node("grid").concrete_spaces=concrete_spaces
	get_parent().get_node("grid").concrete_healths=concrete_healths
	get_parent().get_node("grid").marmalade_spaces=marmalade_spaces
	get_parent().get_node("grid").marmalade_healths=marmalade_healths
	get_parent().get_node("grid").ice_spaces=ice_spaces
	get_parent().get_node("grid").ice_healths=ice_healths
	get_parent().get_node("grid").lock_spaces=lock_spaces
	get_parent().get_node("grid").slime_spaces=slime_spaces
	get_parent().get_node("grid").empty_spaces=empty_spaces
	get_parent().get_node("goal_holder").score_goal_enabled=score_goal_enabled
	get_parent().get_node("score_goal").score_needed=score_needed
	get_parent().get_node("score_goal").max_score_star=max_score_star
	get_parent().get_node("grid").width=width
	get_parent().get_node("grid").height=height
	get_parent().get_node("grid").y_start=y_start
	get_parent().get_node("grid").x_start=x_start
	get_parent().get_node("grid").current_counter_value=current_counter_value
	
var signal_count=1
func level_editor():
	emit_signal("spawn_debug",3,4,"pink","column",true) ##for functionality doesnt effect grid

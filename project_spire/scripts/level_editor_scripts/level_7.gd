extends Node2D
signal spawn_debug(i,j,color,type)

var x_starts=[470,412,355,297,240,182,125]
var y_starts=[1469,1536,1334,1671,1739,1806,1875]
#set these values
#set goal holder values
#copy paste level editor prints and signal_count

var level=7
#yellow=0 , pink=1 , orange=2 , purple=3 ,green=4 ,blue=5 ,
var weights = [0, 0, 0, 0, 0, 2]
var current_counter_value=25
var width=7
var height=7
var score_needed=3000
var max_score_star=3000
var score_goal_enabled=false
#obstacles spaces args are vec2s
var ice_spaces=[]
var ice_healths=[]
var lock_spaces=[]
var concrete_spaces=[Vector2(0,0), Vector2(2,0), Vector2(4,0), Vector2(6,0), Vector2(5,1), Vector2(4,1), Vector2(2,1), Vector2(1,1), Vector2(1,2), Vector2(0,2), Vector2(4,2), Vector2(6,2), Vector2(5,3), Vector2(4,3), Vector2(2,3), Vector2(1,3), Vector2(2,4), Vector2(1,4), Vector2(0,4), Vector2(4,4), Vector2(5,4), Vector2(5,5), Vector2(4,5), Vector2(3,5), Vector2(2,5), Vector2(1,5), Vector2(0,6), Vector2(6,6), Vector2(4,6), Vector2(3,6), Vector2(2,6), Vector2(6,4), Vector2(5,2)]
var concrete_healths=[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
var slime_spaces=[]
var empty_spaces=[]
var marmalade_spaces=[]
var marmalade_healths=[]
var sinker_amount=0

var x_start = x_starts[width-3]
var y_start = y_starts[height-3]

func _ready():
	get_parent().get_node("grid").level=level
	get_parent().get_node("grid").weights=weights
	get_parent().get_node("grid").marmalade_spaces=marmalade_spaces
	get_parent().get_node("grid").marmalade_healths=marmalade_healths
	GameDataManager.modify_dict(0,"free_switch_booster_unlocked",true)
	get_parent().get_node("grid").sinker_amount=sinker_amount
	get_parent().get_node("grid").concrete_spaces=concrete_spaces
	get_parent().get_node("grid").ice_spaces=ice_spaces
	get_parent().get_node("grid").lock_spaces=lock_spaces
	get_parent().get_node("grid").concrete_healths=concrete_healths
	get_parent().get_node("grid").ice_healths=ice_healths
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
	
	
var signal_count=16 #DONT FORGET SIGNAL COUNT & COMMENT FIRST LINE IF THERE ARE OTHERS
func level_editor():
	emit_signal("spawn_debug",1,6,"blue","regular")
	emit_signal("spawn_debug",0,5,"blue","regular")
	emit_signal("spawn_debug",0,3,"blue","regular")
	emit_signal("spawn_debug",0,1,"blue","regular")
	emit_signal("spawn_debug",1,0,"blue","regular")
	emit_signal("spawn_debug",5,0,"blue","regular")
	emit_signal("spawn_debug",6,1,"blue","regular")
	emit_signal("spawn_debug",6,3,"blue","regular")
	emit_signal("spawn_debug",6,5,"blue","regular")
	emit_signal("spawn_debug",5,6,"blue","regular")
	emit_signal("spawn_debug",3,4,"pink","regular")
	emit_signal("spawn_debug",3,3,"pink","regular")
	emit_signal("spawn_debug",2,2,"pink","regular")
	emit_signal("spawn_debug",3,1,"pink","regular")
	emit_signal("spawn_debug",3,0,"pink","regular")
	emit_signal("spawn_debug",3,2,"blue","regular")
	

#-------------
#1.3-custom fall paths & more levels
#-------------
extends Node2D

@export var width:int
@export var height:int 
enum {wait,move,win,booster,free_switch}
var state
#x_y start value automator
#var x_starts=[470,412,355,297,240,182,125]
#var y_starts=[1469,1536,1334,1671,1739,1806,1875]
#var x_start = x_starts[width-3]
#var y_start = y_starts[height-3]
@export var x_start:int
@export var y_start:int
var offset_x = 115
var offset_y = 135
var height_offset=3
#------------------------------------------------------------
var slime_pieces=[]
var slime=preload("res://scenes/special_piece_scenes/slime.tscn")
signal break_slime
var lock_pieces=[]
var ice_pieces=[]
var ice_healths=[]
var ice_health
var concrete_pieces=[]
var concrete_healths=[]
var concrete_health=1
var marmalade_pieces=[]
var marmalade_healths=[]
var marmalade_health=1
var swirl_pieces=[]
var marmalade=preload("res://scenes/special_piece_scenes/marmalade.tscn")
var swirl=preload("res://scenes/special_piece_scenes/swirl.tscn")
var concrete=preload("res://scenes/special_piece_scenes/concrete.tscn")
var lock=preload("res://scenes/special_piece_scenes/lock.tscn")
var ice=preload("res://scenes/special_piece_scenes/ice.tscn")
signal break_lock
signal break_ice
signal break_concrete
signal break_marmalade
signal break_swirl

#------------------------------------------------------------
#booster1:adds a color bomb
#booster2:3 pieces will turn into adjacent bombs
#booster3:5more moves
#booster4:switches 2 pieces that dont match
#booster5:3 pieces will turn into colrow bombs

var source_color=""
var damaged_slime=false

#camera stuff
signal shake
signal shake_harder

#score_stuff
signal update_current_score
var current_score=0

#sinker stuff
@export var sinker_amount:int
var current_sinkers=0

#effect stuff
var bomb_explode=preload("res://scenes/animation_scenes/bomb_explode.tscn")
var bomb_spawn=preload("res://scenes/animation_scenes/bomb_spawn.tscn")
var piece_crumble=preload("res://scenes/animation_scenes/piece_crumble.tscn")
var halo_grow=preload("res://scenes/animation_scenes/halo_grow.tscn")
var halo_shrink=preload("res://scenes/animation_scenes/halo_shrink.tscn")
var piece_shrink=preload("res://scenes/animation_scenes/piece_shrink.tscn")

#Preloads a class or variable. (Array makes it easily accesible)
#enabled pieces are activated and used in possible pieces
var main_pieces = [
preload("res://scenes/piece_scenes/main_pieces/yellow_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/pink_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/orange_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/purple_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/green_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/blue_piece.tscn"),
]

var all_pieces = [
preload("res://scenes/piece_scenes/main_pieces/yellow_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/pink_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/orange_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/purple_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/green_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/blue_piece.tscn"),
preload("res://scenes/piece_scenes/main_pieces/blocker.tscn"),
]

var array = []
var clone_array=[]
var current_matches=[]
var color_bomb_used =false
var level_editor

		
func _ready():
	randomize()
	state = move
	array = make_2d_array()
	clone_array=make_2d_array()
	get_parent().get_node("level_editor").level_editor()
#	spawn_ice()
	spawn_grid()
	spawn_slime(position)
	spawn_swirl()
	spawn_sinker(sinker_amount)
	spawn_concrete()
	spawn_lock()
	spawn_marmalade()
	emit_signal("update_counter",current_counter_value)
	no_longer_restricted_spaces.clear()
	
	
var signal_count=0
func _on_level_editor_spawn_debug(i,j,color,type,query=false):
	if query:
		spawn_pieces()
	else:
		var color_map = {
		"yellow":0,
		"pink":1,
		"orange":2,
		"purple":3,
		"green":4,
		"blue":5,
		"blocker":6,
		}
		var int_color=color_map[color]
		var piece = all_pieces[int_color].instantiate()
		match type:
			"regular":
				pass
			"column":
				piece.make_column_bomb()
			"row":
				piece.make_row_bomb()
			"adjacent":
				piece.make_adjacent_bomb()
			"color":
				piece.make_color_bomb()
			"fish":
				piece.make_fish()
			"sinker":
				piece.make_sinker()
		add_child(piece)
		array[i][j]=piece
		piece.position = grid_to_pixel(i,j)
		debug_spaces.append(Vector2(i,j))
		signal_count+=1
		if signal_count==get_parent().get_node("level_editor").signal_count:
			spawn_pieces()
			signal_count=0

	
func debug_fill(place):
	if is_in_array(debug_spaces,place) :
		return true

func is_in_array(list,item):
	if array!=null:
		for i in list.size() :
			if list[i]==item :
				return true
		return false

var no_longer_restricted_spaces=[]

func restricted_fill(place):
	if is_in_array(get_parent().get_node("level_editor").empty_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
#	if is_in_array(get_parent().get_node("level_editor").concrete_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
#		return true
	if is_in_array(get_parent().get_node("level_editor").slime_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
#	if is_in_array(get_parent().get_node("level_editor").marmalade_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
#		return true
	if is_in_array(get_parent().get_node("level_editor").concrete_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
	return false

func empty_fill(place):
	if is_in_array(empty_spaces,place):
		return true

func restricted_move(place):
	if is_in_array(get_parent().get_node("level_editor").lock_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
	if is_in_array(get_parent().get_node("level_editor").concrete_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
	if is_in_array(get_parent().get_node("level_editor").marmalade_spaces,place) and !is_in_array(no_longer_restricted_spaces,place):
		return true
	return false

#godot runs throgh the rows first bcs its the second for loop
#array starts with (0,0)
func make_2d_array():
	var empty_array = []
	for i in width:
		empty_array.append([])
		for j in height:
			empty_array[i].append(null)
	return  empty_array

func is_in_grid(grid_position):
	if grid_position.x>=0 and grid_position.x<width:
		if grid_position.y>=0 and grid_position.y<height:
			return true
	return false

var grid_piece_scene=preload("res://scenes/grid_scenes/grid_scene.tscn")
func spawn_grid():
	for i in width:
		for j in height:
			if !empty_fill(Vector2(i,j)):
				var grid_piece=grid_piece_scene.instantiate()
				grid_piece.position=grid_to_pixel(i,j)
				var node_to_add=get_parent().get_node("grid_bg")
				node_to_add.add_child(grid_piece)

#swap back variables
var piece_1 =null
var piece_2 =null
var last_place = Vector2(0,0)
var last_direction =Vector2(0,0)

#touch variables
var controlling = false
var press = Vector2(0,0)
var release = Vector2(0,0)

#scoring variables
signal update_score
var piece_value=10
var streak=1

#counter variables
signal update_counter
@export var current_counter_value:int
var is_moves=true
signal game_over
#goal check 
signal check_goal

#deadlock 
signal deadlocked

#obstacle stuff
@export var ice_spaces:PackedVector2Array
@export var lock_spaces:PackedVector2Array
@export var concrete_spaces:PackedVector2Array
@export var slime_spaces:PackedVector2Array
@export var empty_spaces:PackedVector2Array
@export var debug_spaces:PackedVector2Array
@export var marmalade_spaces:PackedVector2Array
@export var swirl_spaces:PackedVector2Array

var debug_press
var debug_piece
var debug_color="null"
var health=0
func debug_input():
	if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)) :
			debug_press = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			debug_piece=array[debug_press.x][debug_press.y]
			
			#obstacles if !is in array
			if Input.is_action_just_pressed("i_key") :
				ice_spaces.append(Vector2(debug_press.x,debug_press.y))
				ice_healths.append(ice_health)
				print("ice_spaces:"+str(ice_spaces))
				print(ice_healths)
			if Input.is_action_just_pressed("l_key") :
				lock_spaces.append(Vector2(debug_press.x,debug_press.y))
				print("lock_spaces:"+str(lock_spaces))
			if Input.is_action_just_pressed("c_key") :
				concrete_spaces.append(Vector2(debug_press.x,debug_press.y))
				concrete_healths.append(concrete_health)
				print("concrete_spaces:"+str(concrete_spaces))
				print(concrete_healths)
			if Input.is_action_just_pressed("e_key") :
				empty_spaces.append(Vector2(debug_press.x,debug_press.y))
				print("empty_spaces:"+str(empty_spaces))
			if Input.is_action_just_pressed("m_key") :
				marmalade_spaces.append(Vector2(debug_press.x,debug_press.y))
				print("marmalade_spaces:"+str(marmalade_spaces))
				marmalade_healths.append(marmalade_health)
				print("marmalade_spaces:"+str(marmalade_spaces))
				print(marmalade_healths)
			if Input.is_action_just_pressed("s_key") :
				swirl_spaces.append(Vector2(debug_press.x,debug_press.y))
				print("swirl_spaces:"+str(swirl_spaces))
			
			#color stuff
			if Input.is_action_just_pressed("color_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",regular"+")")
			
			#bomb stuff col-row-adj-color
			if Input.is_action_just_pressed("1_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",column"+")")
			
			if Input.is_action_just_pressed("2_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",row"+")")
			
			if Input.is_action_just_pressed("3_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",adjacent"+")")
			
			if Input.is_action_just_pressed("4_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",color"+")")
			
			if Input.is_action_just_pressed("5_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+"green"+",sinker"+")")
			
			if Input.is_action_just_pressed("6_key"):
				print("emit_signal("+"spawn_debug"+","+str(debug_press.x)+","+str(debug_press.y)+","+str(debug_color)+",fish"+")")

var halo_used=false
signal released
#release-input>touch-difference>swap 
func touch_input(free_switch_query=false):
	if free_switch_query:
		if Input.is_action_just_pressed("ui_touch") :
			if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)) :
				press = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
				controlling = true
		if Input.is_action_just_released("ui_touch"):
			if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y))  && controlling :
				release =pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
				touch_difference_for_booster(press,release)
				controlling=false
				emit_signal("released")
	else:
		if Input.is_action_just_pressed("ui_touch") :
			if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)) :
				press = pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
				controlling = true
		if Input.is_action_just_released("ui_touch"):
#			if is_in_grid(pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y))  && controlling :
			release =pixel_to_grid(get_global_mouse_position().x,get_global_mouse_position().y)
			touch_difference(press,release)
			controlling=false
		
func swap_pieces_for_booster(column,row,direction):
	
	SoundManager.play_fixed_sound("swap_pieces")
	press_piece=array[column][row]
	release_piece=array[column+direction.x][row+direction.y]
	released_column=column+direction.x
	released_row=row+direction.y
	if press_piece!=null and release_piece!=null:
		pos_press=pixel_to_grid(press_piece.position.x,press_piece.position.y)
		pos_release=pixel_to_grid(release_piece.position.x,release_piece.position.y)
	
	store_info(press_piece,release_piece,Vector2(column,row),direction)
	state = wait
	array[column][row]=release_piece
	array[column+direction.x][row+direction.y]=press_piece
	if press_piece!=null and press_piece.is_pseudo_adjacent_bomb!=true:
		press_piece.move(grid_to_pixel(column+direction.x,row+direction.y))
	if !halo_used :
		make_effect(halo_shrink,column,row,"halo_shrink")
		make_effect(halo_shrink,column+direction.x,row+direction.y,"halo_shrink")
	if release_piece!=null and release_piece.is_pseudo_adjacent_bomb!=true:
		release_piece.move(grid_to_pixel(column,row))
	SoundManager.play_fixed_sound("booster_spawn_4")
	state=move

var released_column
var released_row
var press_piece
var release_piece
var pos_press
var pos_release

#swap>findmatches>destroytimer>destroymatch(nomatch)>swapback>swappieces
#runs find_and_spawn_bombs unless query query only true if swap_back
var bombs_were_found_after_swap
func swap_pieces(column,row,direction,query=false):
	bombs_were_found_after_swap=false
	SoundManager.play_fixed_sound("swap_pieces")
	press_piece=array[column][row]
	release_piece=array[column+direction.x][row+direction.y]
	released_column=column+direction.x
	released_row=row+direction.y
	if press_piece!=null and release_piece!=null:
		pos_press=pixel_to_grid(press_piece.position.x,press_piece.position.y)
		pos_release=pixel_to_grid(release_piece.position.x,release_piece.position.y)
	
	if press_piece!=null and release_piece!=null :
		if !restricted_move(Vector2(column,row)) and !restricted_move(Vector2(column,row) + direction) :

			#colorcolorinteraction
			if press_piece.color=="color" and release_piece.color=="color" :
				clear_board()
			
			#fish+adjacent
			if press_piece!=null and release_piece!=null:
				if press_piece.is_adjacent_bomb and release_piece.is_fish:
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					fish_adjacent()
					print("fishadjacent1")
			if press_piece!=null and release_piece!=null:
				if release_piece.is_adjacent_bomb and press_piece.is_fish:
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					fish_adjacent()
					print("fishadjacent2")
			
			#fish+colrow
			if press_piece!=null and release_piece!=null:
				if press_piece.is_column_bomb and release_piece.is_fish or press_piece.is_row_bomb and release_piece.is_fish or press_piece.is_fish and release_piece.is_row_bomb or press_piece.is_fish and release_piece.is_column_bomb :
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					fish_colrow()
					print("fishcolrow1")
#			if press_piece!=null and release_piece!=null:
#				if release_piece.is_column_bomb or release_piece.is_row_bomb and press_piece.is_fish:
#					press_piece.queue_free()
#					press_piece=null
#					release_piece.queue_free()
#					release_piece=null
#					fish_colrow()
#					print("fishcolrow2")
			
			#colorcolrowinteraction1
			if press_piece!=null and release_piece!=null:
				if press_piece.color=="color" and release_piece.is_column_bomb or press_piece.color=="color" and release_piece.is_row_bomb:
					color_colrow(release_piece.color)
					effect_animator(press_piece.color,pos_press.x,pos_press.y)
					effect_animator(release_piece.color,pos_release.x,pos_release.y)
					make_particle_effect(pos_press.x,pos_press.y)
					make_particle_effect(pos_release.x,pos_release.y)
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					print("color+colrow1")
					
			#colorcolrowinteraction2
			if press_piece!=null and release_piece!=null:
				if press_piece.is_column_bomb and release_piece.color=="color" or press_piece.is_row_bomb and release_piece.color=="color":
					color_colrow(press_piece.color)
					effect_animator(press_piece.color,pos_press.x,pos_press.y)
					effect_animator(release_piece.color,pos_release.x,pos_release.y)
					make_particle_effect(pos_press.x,pos_press.y)
					make_particle_effect(pos_release.x,pos_release.y)
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					print("color+colrow2")
					
			#coloradjacentinteraction1
			if press_piece!=null and release_piece!=null:
				if press_piece.color=="color" and release_piece.is_adjacent_bomb==true:
					print("coloradjacent1")
					color_adjacent(release_piece.color)
					destroy_specials_adjacent(pos_release.x,pos_release.y,release_piece.color)
					effect_animator(press_piece.color,pos_press.x,pos_press.y)
					effect_animator(release_piece.color,pos_release.x,pos_release.y)
					make_particle_effect(pos_press.x,pos_press.y)
					make_particle_effect(pos_release.x,pos_release.y)
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
				
			#coloradjacentinteraction2
			if press_piece!=null and release_piece!=null:
				if press_piece.is_adjacent_bomb==true and release_piece.color=="color":
					print("coloradjacent2")
					color_adjacent(press_piece.color)
					destroy_specials_adjacent(pos_press.x,pos_press.y,press_piece.color)
					effect_animator(press_piece.color,pos_press.x,pos_press.y)
					effect_animator(release_piece.color,pos_release.x,pos_release.y)
					make_particle_effect(pos_press.x,pos_press.y)
					make_particle_effect(pos_release.x,pos_release.y)
					press_piece.queue_free()
					press_piece=null
					release_piece.queue_free()
					release_piece=null
					
			#colorregularinteraction
			if press_piece!=null and release_piece!=null:
				if press_piece.is_color_bomb and release_piece.is_sinker or press_piece.is_sinker and release_piece.is_color_bomb:
					swap_back()
					print("color_regular1")
				if press_piece.color =="color" and release_piece.is_special==false and press_piece.color!="blocker" :
					if press_piece.is_fish!=true and release_piece.is_fish!=true:
						match_color(release_piece.color)
						match_and_add_to_matches(pos_press.x,pos_press.y)
						print("color_regular2")
				if release_piece.color=="color" and press_piece.is_special==false and release_piece.color!="blocker" :
					match_color(press_piece.color)
					match_and_add_to_matches(pos_release.x,pos_release.y)
					print("color_regular3")
					
			#adjadjinteraction 
			#2x2 explosion #dont destroy press,release pieces but explode and change them to bright pseudo adjbombs
			#they start shaking and glowing  #after refill 2x2 explosion and destruction 
			if press_piece!=null and release_piece!=null:
				if press_piece.is_adjacent_bomb and release_piece.is_adjacent_bomb:
					SoundManager.play_fixed_sound("adjacent_combine")
					var pres_color=press_piece.color
					var release_color=release_piece.color
					press_piece.make_pseudo_adjacent_bomb()
					release_piece.make_pseudo_adjacent_bomb()
					destroy_adjacent_for_adjacentadjacent(pos_press.x,pos_press.y,pres_color)
					destroy_adjacent_for_adjacentadjacent(pos_release.x,pos_release.y,release_color)
					adj_adj2(pres_color,release_color)
					emit_signal("check_goal","adjacent")
					emit_signal("check_goal","adjacent")
					emit_signal("check_goal","striped")
					emit_signal("check_goal","striped")
					print("adj+adj")
				
			#colrow+adjacentinteraction1
			if press_piece!=null and release_piece!=null:
				if press_piece.is_column_bomb or press_piece.is_row_bomb:
					if release_piece.is_adjacent_bomb:
						press_piece.is_row_bomb=false
						release_piece.is_row_bomb=false
						press_piece.is_column_bomb=false
						release_piece.is_column_bomb=false
						press_piece.is_adjacent_bomb=false
						release_piece.is_adjacent_bomb=false
						var release_color
						release_color=release_piece.color
						for w in range(-1,2):
							if pos_press.x+w>=0 and pos_press.y+w<width:
								destroy_specials_row(pos_release.x,pos_release.y+w)
								if w!=0:
									make_bomb_explode_effects("row",release_color,pos_release.x,pos_release.y+w)
								SoundManager.play_fixed_sound("whoosh")
						await get_tree().create_timer(0.5).timeout
						for h in range(-1,2):
							if pos_press.x+h>=0 and pos_press.x+h<height:
								destroy_specials_column(pos_press.x+h,pos_press.y)
								if h!=0:
									make_bomb_explode_effects("column",release_color,pos_press.x+h,pos_press.y)
								SoundManager.play_fixed_sound("whoosh")
						emit_signal("shake_harder")
						print("colrow+adjacent1")
						
			#colrow+adjacentinteraction2
			if press_piece!=null and release_piece!=null:
				if press_piece.is_adjacent_bomb:
					if release_piece.is_column_bomb or release_piece.is_row_bomb:
						press_piece.is_row_bomb=false
						release_piece.is_row_bomb=false
						press_piece.is_column_bomb=false
						release_piece.is_column_bomb=false
						press_piece.is_adjacent_bomb=false
						release_piece.is_adjacent_bomb=false
						var release_color
						release_color=release_piece.color
						for w in range(-1,2):
							if pos_press.y+w>=0 and pos_press.y+w<width:
								destroy_specials_row(pos_press.x,pos_press.y+w)
								if w!=0:
									make_bomb_explode_effects("row",release_color,pos_press.x,pos_press.y+w)
								SoundManager.play_fixed_sound("whoosh")
						await get_tree().create_timer(0.5).timeout
						for h in range(-1,2):
							if pos_release.x+h>=0 and pos_release.x+h<height:
								destroy_specials_column(pos_release.x+h,pos_release.y)
								if h!=0:
									make_bomb_explode_effects("column",release_color,pos_release.x+h,pos_release.y)
								SoundManager.play_fixed_sound("whoosh")
						emit_signal("shake_harder")
						print("colrow+adjacent2")
						
			#colrow_interaction1
			if press_piece!=null and release_piece!=null:
				if press_piece.is_column_bomb and release_piece.is_row_bomb:
					match_and_add_to_matches(pos_press.x,pos_press.y)
					match_and_add_to_matches(pos_release.x,pos_release.y)
					print("col+row1")
			#colrow_interaction2
			if press_piece!=null and release_piece!=null:
				if press_piece.is_row_bomb and release_piece.is_column_bomb:
					match_and_add_to_matches(pos_press.x,pos_press.y)
					match_and_add_to_matches(pos_release.x,pos_release.y)
					print("col+row2")
					
			#rest
			store_info(press_piece,release_piece,Vector2(column,row),direction)
			state = wait
			array[column][row]=release_piece
			array[column+direction.x][row+direction.y]=press_piece
			if press_piece!=null and press_piece.is_pseudo_adjacent_bomb!=true:
				press_piece.move(grid_to_pixel(column+direction.x,row+direction.y))
			if !halo_used :
				make_effect(halo_shrink,column,row,"halo_shrink")
				make_effect(halo_shrink,column+direction.x,row+direction.y,"halo_shrink")
			if release_piece!=null and release_piece.is_pseudo_adjacent_bomb!=true:
				release_piece.move(grid_to_pixel(column,row))
			if query:
				pass
			else:
				find_and_spawn_bombs(true)
				if find_and_spawn_bombs:
					bombs_were_found_after_swap=true
				else:
					bombs_were_found_after_swap=false
	
#part 2 of adj+adj
func adj_adj2(presscolor,releasecolor):
	var presspiece
	var releasepiece
	var presscord
	var releasecord
	for i in width:
		for j in height:
			var piece=array[i][j]
			if piece!=null:
				if piece.is_pseudo_adjacent_bomb:
					if piece.color==presscolor:
						presspiece=array[i][j]
						presscord=Vector2(i,j)
					if piece.color==releasecolor:
						releasepiece=array[i][j]
						releasecord=Vector2(i,j)
	
	presspiece.wiggle_for_adjacent("left")
	releasepiece.wiggle_for_adjacent("right")
	#adjadj timers
	await get_tree().create_timer(.6).timeout
	collapse_columns()
	await get_tree().create_timer(.6).timeout
	
	destroy_adjacent_for_adjacentadjacent(presscord.x,presscord.y,presscolor,true)
	destroy_adjacent_for_adjacentadjacent(releasecord.x,releasecord.y,releasecolor,true)
	await get_tree().create_timer(.6).timeout
	collapse_columns()
	print("adj_adj2")

#helper method for color+colrow interaction
func color_colrow(color):
	for i in width:
		for j in height:
			var piece=array[i][j]
			var current_color=array[i][j].color
			if current_color==color:
				var rand = randi_range(0,100)
				if rand>=50:
					piece.make_column_bomb()
					piece.matched=false
				else:
					piece.make_row_bomb()
					piece.matched=false
	print("color_colrow_p1")
	color_colrow2()

#part 2 of color_colrow
var color_colrow2_array=[]
func color_colrow2():
	color_colrow2_array.clear()
	await get_tree().create_timer(0.1).timeout
	for i in width:
		for j in height:
			var piece=array[i][j]
			if piece!=null:
				if piece.is_row_bomb or piece.is_column_bomb:
					if_not_has_add_to_array(Vector2(i,j),color_colrow2_array)
					await get_tree().create_timer(0.1).timeout
					if array[i][j]!=null:
						array[i][j].matched=true
						if array[i][j]!=null:
							if array[i][j].is_row_bomb:
								destroy_specials_row(i,j)
						if array[i][j]!=null:
							if array[i][j].is_column_bomb:
								destroy_specials_column(i,j)
	print("color_colrow_p2")

#helper method for adj+color interaction
var color_adjacent_array=[]
func color_adjacent(color):
	color_adjacent_array.clear()
	for i in width:
		for j in height:
			var piece=array[i][j]
			var current_color=array[i][j].color
			if current_color==color:
				piece.make_adjacent_bomb()
				if_not_has_add_to_array(Vector2(i,j),color_adjacent_array)
	await get_tree().create_timer(0.1).timeout
	for k in color_adjacent_array.size():
		var piece=array[color_adjacent_array[k].x][color_adjacent_array[k].y]
		if piece!=null:
			piece.matched=true
			destroy_specials(true)
			await get_tree().create_timer(0.1).timeout
	print("color_adjacent")
	await get_tree().create_timer(.4).timeout
	collapse_columns()
			
func swap_back():
	if piece_1!=null and piece_2!=null:
		halo_used=true
		SoundManager.play_fixed_sound("swap_back")
		swap_pieces(last_place.x,last_place.y,last_direction,true)
		halo_used=false
	state=move
	$hint_timer.start()


func is_color_bomb(piece_one,piece_two):
	if piece_one.color=="color" or piece_two.color=="color" :
		color_bomb_used=true
		return true
	else :
		return false

# warning-ignore:shadowed_variable
func store_info(_pressed_piece,_released_piece,place,direction):
	piece_1 =press_piece
	piece_2 =release_piece
	last_place=place
	last_direction=direction


#which piece needs to move in which direction right left down up
func touch_difference(first,second):
	var difference =second-first
	if abs(difference.x) > abs(difference.y) :
		if difference.x>0 and first.x!=height-1 :
			swap_pieces(first.x,first.y,Vector2(1,0))
		elif difference.x<0 and first.x!=0 :
			swap_pieces(first.x,first.y,Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x) :
		if difference.y >0 and first.y!=height-1 :
			swap_pieces(first.x,first.y,Vector2(0,1))
		elif difference.y <0 and first.y!=0 :
			swap_pieces(first.x,first.y,Vector2(0,-1))

#which piece needs to move in which direction right left down up
func touch_difference_for_booster(first,second):
	var difference =second-first
	if abs(difference.x) > abs(difference.y) :
		if difference.x>0 and first.x!=height-1 :
			swap_pieces_for_booster(first.x,first.y,Vector2(1,0))
		elif difference.x<0 and first.x!=0 :
			swap_pieces_for_booster(first.x,first.y,Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x) :
		if difference.y >0 and first.y!=height-1 :
			swap_pieces_for_booster(first.x,first.y,Vector2(0,1))
		elif difference.y <0 and first.y!=0 :
			swap_pieces_for_booster(first.x,first.y,Vector2(0,-1))

func grid_to_pixel(column,row):
	var pixel_column = (x_start) + (offset_x * column)
	var pixel_row = y_start + (-offset_y * row)
	return Vector2(pixel_column,pixel_row)
	

func pixel_to_grid(pixel_column,pixel_row):
	var grid_column = round((pixel_column - x_start) / offset_x)
	var grid_row = round((pixel_row - y_start) / -offset_y)
	return Vector2(grid_column,grid_row)

#not using var for a variable will make the scope global
#Instanced variable is created and stored in memory, but for it to be visible,it has to be added as a child to the scene tree.
func spawn_pieces():
	spawn_ice()
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i,j)) and array[i][j]==null and !debug_fill(Vector2(i,j)):
				#choose random number and store it 
				var rand = randi_range(0,main_pieces.size()-1)
				var piece = main_pieces[rand].instantiate()
				var _loops=0
				while match_at(i,j,piece.color) and _loops<100:
					rand=randi_range(0,main_pieces.size()-1)
					_loops+=1
					piece=main_pieces[rand].instantiate()
				#instance that piece from the array
				add_child(piece)
				array[i][j]=piece
				piece.position = grid_to_pixel(i,j)
	if await is_deadlocked():
		shuffle_board()
		pass
	$hint_timer.start()

func spawn_ice():
	if ice_spaces!=null:
		for i in ice_spaces.size():
			if ice_pieces.size() ==0:
				ice_pieces=make_2d_array()
			var current = ice.instantiate()
			add_child(current)
			current.health=ice_healths[i]
			current.text_setter()
			position=ice_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			ice_pieces[position.x][position.y]=current

func is_piece_sinker(column,row):
	if array[column][row] != null :
		if array[column][row].color == "sinker" :
			return true
	return false

func is_piece_fish(column,row):
	if array[column][row] != null :
		if array[column][row].is_fish == true :
			return true
	return false
	
func is_piece_special(column,row):
	if array[column][row] != null :
		if array[column][row].is_special == true :
			return true
	return false

func spawn_lock():
	if lock_spaces!=null:
		for i in lock_spaces.size():
			if lock_pieces.size() ==0:
				lock_pieces=make_2d_array()
			var current = lock.instantiate()
			add_child(current)
			position=lock_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			lock_pieces[position.x][position.y]=current

func spawn_concrete():
	if concrete_spaces!=null:
		for i in concrete_spaces.size():
			if concrete_pieces.size() ==0:
				concrete_pieces=make_2d_array()
			var current = concrete.instantiate()
			add_child(current)
			current.health=concrete_healths[i]
			current.text_setter()
			position=concrete_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			concrete_pieces[position.x][position.y]=current

func spawn_marmalade():
	if marmalade_spaces!=null:
		for i in marmalade_spaces.size():
			if marmalade_pieces.size() ==0:
				marmalade_pieces=make_2d_array()
			var current = marmalade.instantiate()
			add_child(current)
			current.health=marmalade_healths[i]
			current.text_setter()
			position=marmalade_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			marmalade_pieces[position.x][position.y]=current

func spawn_swirl():
	if swirl_spaces!=null:
		for i in swirl_spaces.size():
			if swirl_pieces.size() ==0:
				swirl_pieces=make_2d_array()
			var current = swirl.instantiate()
			add_child(current)
			position=swirl_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			swirl_pieces[position.x][position.y]=current

@warning_ignore("shadowed_variable_base_class")
func spawn_slime(position):
	if slime_spaces!=null:
		for i in slime_spaces.size():
			if slime_pieces.size() ==0:
				slime_pieces=make_2d_array()
			var current = slime.instantiate()
			add_child(current)
			position=slime_spaces[i]
			current.position=grid_to_pixel(position.x,position.y)
			slime_pieces[position.x][position.y]=current

func spawn_sinker(number_to_spawn):
	for i in number_to_spawn:
		var column=randi_range(0,width-1)
		var piece=array[column][height-1]
		while piece!=null and piece.is_sinker==true:
			column=randi_range(0,width-1)
			piece=array[column][height-1]
		var current=array[column][height-1]
		if current!=null:
			current.make_sinker()
			current_sinkers+=1

#used when creating the board without matches
func match_at(i,j,color):
	#checks left
	if color!="sinker":
		if i>1 :
			if array[i - 1][j] != null and array[i - 2][j] != null:
				if array[i-1][j].color == color and array[i-2][j].color == color:
					return true
		#checks down
		if j>1 :
			if array[i][j - 1] != null and array[i][j - 2] != null:
				if array[i][j-1].color == color and array[i][j-2].color == color:
					return true
		#checks right
		if i<width-2 :
			if array[i + 1][j] != null and array[i + 2][j] != null:
				if array[i+1][j].color == color and array[i+2][j].color == color:
					return true
		#checks up
		if j<height-2 :
			if array[i][j + 1] != null and array[i][j + 2] != null:
				if array[i][j+1].color == color and array[i][j+2].color == color:
					return true
		#checks up&down
		if j>1 and j<height-1:
			if array[i][j + 1] != null and array[i][j -1] != null:
				if array[i][j+1].color == color and array[i][j-1].color == color:
					return true
		#check left&right
		if i>1 and i<width-1 :
			if array[i + 1][j] != null and array[i -1][j] != null:
				if array[i+1][j].color == color and array[i-1][j].color == color:
					return true
		
		
func effect_animator(color,column,row):
	if color=="blue":
		make_effect(piece_crumble,column,row,"blue_crumble")
		make_effect(piece_shrink,column,row,"blue_shrink")
		make_effect(halo_grow,column,row,"blue_grow")
	elif color=="green":
		make_effect(piece_crumble,column,row,"green_crumble")
		make_effect(piece_shrink,column,row,"green_shrink")
		make_effect(halo_grow,column,row,"green_grow")
	elif color=="purple":
		make_effect(piece_crumble,column,row,"purple_crumble")
		make_effect(piece_shrink,column,row,"purple_shrink")
		make_effect(halo_grow,column,row,"purple_grow")
	elif color=="orange":
		make_effect(piece_crumble,column,row,"orange_crumble")
		make_effect(piece_shrink,column,row,"orange_shrink")
		make_effect(halo_grow,column,row,"orange_grow")
	elif color=="pink":
		make_effect(piece_crumble,column,row,"pink_crumble")
		make_effect(piece_shrink,column,row,"pink_shrink")
		make_effect(halo_grow,column,row,"pink_grow")
	elif color=="yellow":
		make_effect(piece_crumble,column,row,"yellow_crumble")
		make_effect(piece_shrink,column,row,"yellow_shrink")
		make_effect(halo_grow,column,row,"yellow_grow")
	elif color=="ice":
		make_effect(piece_crumble,column,row,"ice_crumble")
	elif color=="slime":
		make_effect(piece_crumble,column,row,"slime_crumble")
	elif color=="concrete":
		make_effect(piece_crumble,column,row,"concrete_crumble")
	elif color=="lock":
		make_effect(piece_crumble,column,row,"lock_crumble")
	elif color=="sinker":
		make_effect(piece_crumble,column,row,"sinker_crumble")
	elif color=="marmalade":
		make_effect(piece_crumble,column,row,"marmalade_crumble")
	elif color=="swirl":
		make_effect(piece_crumble,column,row,"swirl_crumble")
	

func make_effect(effect,column,row,animation):
	var current=effect.instantiate()
	current.get_node("AnimationPlayer").play(animation)
	current.position=grid_to_pixel(column,row)
	add_child(current)

func make_bomb_explode_effects(type,color,column,row):
	var effect=bomb_explode.instantiate()
	effect.argument_placer(color)
	add_child(effect)
	
	if type=="column":
		SoundManager.play_fixed_sound("colrow_explode")
		Input.vibrate_handheld(100)
		effect.position=grid_to_pixel(column,row)
		effect.get_node("AnimationPlayer").play("column_bomb_explode")
		
	if type=="row":
		SoundManager.play_fixed_sound("colrow_explode")
		Input.vibrate_handheld(100)
		effect.position=grid_to_pixel(column,row)
		effect.get_node("AnimationPlayer").play("row_bomb_explode")
	
	if type=="adjacent":
		SoundManager.play_fixed_sound("adj_explode")
		Input.vibrate_handheld(100)
		effect.position=grid_to_pixel(column,row)
		effect.get_node("AnimationPlayer").play("adjacent_bomb_explode")
		
	if type=="big_adjacent":
		SoundManager.play_fixed_sound("adj_explode")
		Input.vibrate_handheld(100)
		effect.position=grid_to_pixel(column,row)
		effect.get_node("AnimationPlayer").play("big_adjacent_bomb_explode")
		
	emit_signal("shake_harder")

func make_bomb_spawn_effects(color,column,row):
	var effect=bomb_spawn.instantiate()
	effect.argument_placer(color)
	add_child(effect)
	effect.position=grid_to_pixel(column,row)
	effect.get_node("AnimationPlayer").play("bomb_spawn")

func make_particle_effect(column,row):
	var particles = preload("res://scenes/particle_effect_scenes/particle_effects.tscn")
	var new_particles=particles.instantiate()
	new_particles.position=grid_to_pixel(column,row)
	add_child(new_particles)
	await get_tree().create_timer(0.5).timeout
	new_particles.queue_free()

func is_piece_null(column,row,array_choice=array):
	if array_choice[column][row] ==null :
		return true
	return false

func match_and_add_to_matches(column,row):
	if array[column][row]!=null:
		var piece_to_match=array[column][row]
		piece_to_match.matched=true
		var value=Vector2(column,row)
		if !current_matches.has(value):
			current_matches.append(value)

func if_not_has_add_to_array(value,array_to_add):
	if !array_to_add.has(value) :
		array_to_add.append(value)

func fish_colrow():
	var count=3
	var sound_count=1
	var happened=false
	while count>0:
		var randx = randi() %width
		var randy = randi() %height
		var temp = array[randx][randy]
		while temp == null or temp.is_special==true:
			randx = randi() % width
			randy = randi() % height
			temp = array[randx][randy]
		print(str(randx)+"-"+str(randy))
		var rand = randi_range(0,101)
		if rand>=50:
			make_bomb_spawn_effects(temp.color,randx,randy)
			temp.make_column_bomb()
			SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
		else:
			make_bomb_spawn_effects(temp.color,randx,randy)
			temp.make_row_bomb()
			SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
		temp.matched=true
		count-=1
		sound_count+=1
		state=move
		happened=true
	if happened==true:
		state=move

func fish_adjacent():
	state=wait
	var count=3
	var sound_count=1
	var happened=false
	while count>0:
		var randx = randi() %width
		var randy = randi() %height
		var temp = array[randx][randy]
		while temp == null or temp.is_special==true:
			randx = randi() % width
			randy = randi() % height
			temp = array[randx][randy]
		make_bomb_spawn_effects(temp.color,randx,randy)
		temp.make_adjacent_bomb()
		SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
		temp.matched=true
		count-=1
		sound_count+=1
		state=move
		happened=true
	if happened==true:
		await get_tree().create_timer(2).timeout
		collapse_columns()
		state=move

func fish_match():
	state=wait
	var count=3
	var sound_count=1
	var happened=false
	#create random col row numbers 3 times
	#randi() %8 creates a random integer between 0-7
	while count>0:
		var randx = randi() %width
		var randy = randi() %height
		var temp = array[randx][randy]
		while temp == null or temp.is_special==true:
			randx = randi() % width
			randy = randi() % height
			temp = array[randx][randy]
		match_and_add_to_matches(randx,randy)
		print(str(randx)+"-"+str(randy))
		SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
		count-=1
		sound_count+=1
		happened=true
	if happened==true:
		state=move

var pieces_matched_when_spawning_color_bomb=[]

func find_matches(hint_query=false,array_choice=array,query2=false,swap_query=false):
	pieces_matched_when_spawning_color_bomb.clear()
	for i in width:
		for j in height:
			if array[i][j]!=null and array_choice[i][j]!=null and !restricted_fill(Vector2(i,j)) and array[i][j].color!="blocker":
				var current_color = array_choice[i][j].color
				
				#color_bomb
				if current_color=="color":
					if i<width-2: #horizontal
						if array[i+1][j]!=null and array[i+2][j]!=null:
							if array[i+1][j].color == array[i+2][j].color:
								for r in range(i+1,width):
									if r<width-1 and r>=1:
										if array[r][j]!=null and restricted_fill(Vector2(r,j)):
											if array[r][j].color == array[r-1][j].color or array[r][j].color==array[r+1][j].color :
												if_not_has_add_to_array(Vector2(r,j),pieces_matched_when_spawning_color_bomb)
											else:
												break
					if i>1: #horizontal
						if array[i-1][j]!=null and array[i-2][j]!=null:
							if array[i-1][j].color == array[i-2][j].color:
								for r in range(width+1,i-1):
									if array[r][j]!=null:
										if array[r][j].color==array[r-1][j].color or array[r][j].color==array[r+1][j].color:
											if_not_has_add_to_array(Vector2(r,j),pieces_matched_when_spawning_color_bomb)
										else:
											break
					#---------------------------------------------------------------------
					if j<height-2: #vertical
						if array[i][j+1]!=null and array[i][j+2]!=null:
							if array[i][j+1].color == array[i][j+2].color:
								for r in range(height-1,j+1):
									if array[i][r].color==array[i][r+1] or array[i][r].color==array[i][r-1].color:
										if_not_has_add_to_array(Vector2(i,r),pieces_matched_when_spawning_color_bomb)
									else:
										break
					if j>1: #vertical
						if array[i][j-1]!=null and array[i][j-2]!=null:
							if array[i][j-1].color == array[i][j-2].color:
								for r in range(height+1,j-1): #problem
									if array[i][r]!=null:
										if array[i][r].color==array[i][r+1].color or array[i][r].color==array[i][r-1].color:
											if_not_has_add_to_array(Vector2(i,r),pieces_matched_when_spawning_color_bomb)
										else:
											break
					for t in pieces_matched_when_spawning_color_bomb.size():
						match_and_add_to_matches(pieces_matched_when_spawning_color_bomb[t].x,pieces_matched_when_spawning_color_bomb[t].y)
				#3matches
				if i>0 and i<width-1 :
					if array_choice[i-1][j]!=null && array_choice[i+1][j]!=null && !restricted_fill(Vector2(i,j)):
						if array_choice[i-1][j]!=null and array_choice[i+1][j]!=null and current_color!="sinker" and !restricted_fill(Vector2(i,j)):
							if array_choice[i][j].color==current_color and array_choice[i-1][j].color == current_color and array_choice[i+1][j].color == current_color :
								if hint_query:
									source_color=current_color
									return true
								SoundManager.play_fixed_sound("swap_pieces")
								SoundManager.play_fixed_sound("match")
								SoundManager.play_fixed_sound("cascade_"+str(streak))
								Input.vibrate_handheld(100)
								var n=0
								if streak%5==0:
									n=1
								else:
									n=0
								SoundManager.play_fixed_sound("refill_"+str(streak%5+n))
								if newly_made_specials.size()!=0:
									for k in newly_made_specials.size():
										if newly_made_specials[k]==Vector2(i,j):
											pass
										else:
											match_and_add_to_matches(i,j)
										if newly_made_specials[k]==Vector2(i-1,j):
											pass
										else:
											match_and_add_to_matches(i-1,j)
										if newly_made_specials[k]==Vector2(i+1,j):
											pass
										else:
											match_and_add_to_matches(i+1,j)
								else:
									match_and_add_to_matches(i,j)
									match_and_add_to_matches(i-1,j)
									match_and_add_to_matches(i+1,j)
								if array_choice[i][j].is_fish==true or array_choice[i-1][j].is_fish==true or array_choice[i+1][j].is_fish==true:
									match_and_add_to_matches(i,j)
									match_and_add_to_matches(i+1,j)
									match_and_add_to_matches(i-1,j)
									fish_match()
				#3matches
				if j>0 and j<height-1 :
					if array_choice[i][j]!=null and array_choice[i][j-1]!=null and array_choice[i][j+1]!=null and current_color!="sinker" and !restricted_fill(Vector2(i,j)) :
						if array_choice[i][j].color == current_color and array_choice[i][j-1].color == current_color and array_choice[i][j+1].color == current_color and !restricted_fill(Vector2(i,j)):
							if hint_query:
								source_color=current_color
								return true
							SoundManager.play_fixed_sound("swap_pieces")
							SoundManager.play_fixed_sound("match")
							SoundManager.play_fixed_sound("cascade_"+str(streak))
							Input.vibrate_handheld(100)
							var n=0
							if streak%5==0:
								n=1
							else:
								n=0
							SoundManager.play_fixed_sound("refill_"+str(streak%5+n))
							if newly_made_specials.size()!=0:
								for k in newly_made_specials.size():
									if newly_made_specials[k]==Vector2(i,j):
										pass
									else:
										match_and_add_to_matches(i,j)
									if newly_made_specials[k]==Vector2(i,j-1):
										pass
									else:
										match_and_add_to_matches(i,j-1)
									if newly_made_specials[k]==Vector2(i,j+1):
										pass
									else:
										match_and_add_to_matches(i,j+1)
							else:
								match_and_add_to_matches(i,j)
								match_and_add_to_matches(i,j-1)
								match_and_add_to_matches(i,j+1)
							if array_choice[i][j].is_fish==true or array_choice[i][j-1].is_fish==true or array_choice[i][j+1].is_fish==true:
								match_and_add_to_matches(i,j)
								match_and_add_to_matches(i,j+1)
								match_and_add_to_matches(i,j-1)
								fish_match()
				#3+1 row_bomb
				if i>2 and i<width-3:
					var piece=array[i][j]
					if piece.is_row_bomb:
						for k in range(-3,4):
							if array[i][j]!=null and array[i+k][j]!=null:
								if array[i][j].color==array[i+k][j].color and k!=0:
									if array[i+k][j].matched==true:
										three_plus_one.append("g")
						if three_plus_one.size()==3:
							for p in width:
								if p!=i:
									match_and_add_to_matches(p,j)
							make_bomb_explode_effects("row",current_color,i,j)
							emit_signal("shake_harder")
							effect_animator(current_color,i,j)
							make_particle_effect(i,j)
							print("3+1row")
							
				#3+1 column_bomb
				if j>0 and j<width-3:
					var piece=array[i][j]
					if piece.is_column_bomb:
						for k in range(-1,3):
							if array[i][j]!=null and array[i][j+k]!=null:
								if array[i][j].color==array[i][j+k].color and k!=0:
									if array[i][j+k].matched==true:
										three_plus_one.append("g")
										
				if j>2 and j<width-2:
					var piece=array[i][j]
					if piece.is_column_bomb:
						for k in range(-2,2):
							if array[i][j]!=null and array[i][j+k]!=null:
								if array[i][j].color==array[i][j+k].color and k!=0:
									if array[i][j+k].matched==true:
										three_plus_one.append("g")
										
						if three_plus_one.size()==3:
							for p in height:
								if p!=j:
									match_and_add_to_matches(i,p)
							make_bomb_explode_effects("column",current_color,i,j)
							emit_signal("shake_harder")
							effect_animator(current_color,i,j)
							make_particle_effect(i,j)
							print("3+1col")
							
	if hint_query:
		return false
	print("findmatches")
	print(newly_made_specials)
	print("pieces_matched_when_spawning_color_bomb",pieces_matched_when_spawning_color_bomb)
	
	if swap_query:
		pass
	else:
		if current_matches.size()==0 and newly_made_specials.size()==0:
			get_parent().get_node("swap_timer").start()
	
	#this stops things from happening before swap is done if swap timer is changed this should change as well
	await get_tree().create_timer(.25).timeout
	
	if query2:
		#destroy_timer here
		get_bomb_pieces(true)
	else:
		#destroy_timer here
		get_bomb_pieces()

signal found_and_spawned_bombs
var newly_made_specials=[]
var three_plus_one=[]
var color_not_colorrow
#what does queies do
func find_and_spawn_bombs(query=false,swap_query=false):
	color_not_colorrow=false
	three_plus_one.clear()
	for i in width:
		for j in height:
			if array[i][j] !=null and !is_piece_sinker(i,j) and !restricted_move(Vector2(i,j)) :
				var current_color = array[i][j].color
					
				#color_bomb_horizontal
				if i>1 and i<width-2 :
					if array[i-1][j]!=null and array[i+1][j]!=null and array[i-2][j]!=null and array[i+2][j]!=null:
						if array[i-1][j].color == current_color and array[i+1][j].color == current_color and array[i-2][j].color == current_color and array[i+2][j].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,3)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("horizontalcolorbomb")
							#horizontalcolorbombmadewithcolbomb
							if array[i][j].is_column_bomb:
								for h in height:
									if h!=j:
										match_and_add_to_matches(i,h)
								make_bomb_explode_effects("column",current_color,i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
							#horizontalcolorbombmadewithrowbomb
							if array[i][j].is_row_bomb:
								for w in width:
									if w!=i:
										match_and_add_to_matches(w,j)
								make_bomb_explode_effects("row",current_color,i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
							#horizontalcolorbombmadewithadjacentbomb
							if array[i][j].is_adjacent_bomb:
								print("horizontalcolorbombmadewithadjacentbomb")
								for w in range(-1,+2):
									for h in range(-1,2):
										if Vector2(i+w,j+h)!=Vector2(i,j):
											match_and_add_to_matches(i+w,j+h)
								make_bomb_explode_effects("adjacent",current_color,i,j)
								shock_effect(i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
				#rowbomb
				if i>0 and i<width-2:
					if array[i][j]!=null and array[i-1][j]!=null and array[i+1][j]!=null and array[i+2][j]!=null:#instert left
						if i==released_column and array[i][j].color == current_color and array[i-1][j].color == current_color and array[i+1][j].color == current_color and array[i+2][j].color == current_color:
							
							if i+3<width-1: 
								if array[i+3][j]!=null:
									if array[i+3][j].color==current_color:
										color_not_colorrow=true
							if i-2>=0:
								if array[i-2][j]!=null:
									if array[i-2][j].color==current_color:
										color_not_colorrow=true
							
							if color_not_colorrow==false:
								var piece=array[i][j]
								create_bomb(piece,1)
								if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							
				if i>1 and i<width-1:
					if array[i][j]!=null and array[i-1][j]!=null and array[i+1][j]!=null and array[i-2][j]!=null: #insert right
						if i==released_column and array[i][j].color == current_color and array[i-1][j].color == current_color and array[i+1][j].color == current_color and array[i-2][j].color == current_color:
							
							if i-3>=0:
								if array[i-3][j]!=null:
									if array[i-3][j].color==current_color:
										color_not_colorrow=true
										
							if i+2<width-1:
								if array[i+2][j]!=null:
									if array[i+2][j].color==current_color:
										color_not_colorrow=true
							
							if color_not_colorrow==false:
								var piece=array[i][j]
								create_bomb(piece,1)
								if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
				#-------------------------------------------------------------------
				#color_bomb_vertical
				if j>1 and j<width-3 :
					if array[i][j]!=null and array[i][j-1]!=null and array[i][j+1]!=null and array[i][j-2]!=null and array[i][j+2]!=null:
						if j==released_row and array[i][j-1].color == current_color and array[i][j+1].color == current_color and array[i][j-2].color == current_color and array[i][j+2].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,3)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("verticalcolorbomb")
							#verticalcolorbombmadewithcolbomb
							if array[i][j].is_column_bomb:
								for h in height:
									if h!=j:
										match_and_add_to_matches(i,h)
								make_bomb_explode_effects("column",current_color,i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
							#verticalcolorbombmadewithrowbomb
							if array[i][j].is_row_bomb:
								for w in width:
									if w!=i:
										match_and_add_to_matches(w,j)
								make_bomb_explode_effects("row",current_color,i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
							#verticalcolorbombmadewithadjacentbomb
							if array[i][j].is_adjacent_bomb:
								print("verticalcolorbombmadewithadjacentbomb")
								for w in range(-1,+2):
									for h in range(-1,2):
										if Vector2(i+w,j+h)!=Vector2(i,j):
											match_and_add_to_matches(i+w,j+h)
								make_bomb_explode_effects("adjacent",current_color,i,j)
								shock_effect(i,j)
								emit_signal("shake_harder")
								effect_animator(current_color,i,j)
								make_particle_effect(i,j)
					#columnbomb
				if j>=1 && j<height-2 :
					if array[i][j]!=null and array[i][j-1]!=null and array[i][j+1]!=null and array[i][j+2]!=null: #insert top-1
						if j==released_row and array[i][j-1].color == current_color and array[i][j+1].color == current_color and array[i][j+2].color == current_color:
							
							if j+3<height-1:
								if array[i][j+3]!=null:
									if array[i][j+3].color==current_color:
										color_not_colorrow=true
										
							if j-2>=0:
								if array[i][j-2]!=null:
									if array[i][j-2].color==current_color:
										color_not_colorrow=true
							
							if color_not_colorrow==false:
								var piece=array[i][j]
								create_bomb(piece,2)
								if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
								
				if j>1 && j<height-1:
					if array[i][j]!=null and array[i][j-1]!=null and array[i][j+1]!=null and array[i][j-2]!=null: #insert bottom+1
						if j==released_row and array[i][j-1].color == current_color and array[i][j+1].color == current_color and array[i][j-2].color == current_color :
							
							if j+2<height-1:
								if array[i][j+2]!=null:
									if array[i][j+2].color==current_color:
										color_not_colorrow=true
										
							if j-3>=0:
								if array[i][j-3]!=null:
									if array[i][j-3].color==current_color:
										color_not_colorrow=true
							
							if color_not_colorrow==false:
								var piece=array[i][j]
								create_bomb(piece,2)
								if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							
				#adjacent_bomb -1,0,1
				if i<width-2 and j>1:
					if array[i][j]!=null and array[i+1][j]!=null and array[i+2][j]!=null and array[i][j-1]!=null and array[i][j-2]!=null:
						if array[i][j].color == current_color and array[i+1][j].color == current_color and array[i+2][j].color == current_color and array[i][j-1].color == current_color and array[i][j-2].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,0)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("findandspawnadjacentA")
				if i>1 and j>1:
					if array[i][j]!=null and array[i-1][j]!=null and array[i-2][j]!=null and array[i][j-1]!=null and array[i][j-2]!=null:
						if array[i][j].color == current_color and array[i-1][j].color == current_color and array[i-2][j].color == current_color and array[i][j-1].color == current_color and array[i][j-2].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,0)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("findandspawnadjacentB")
				if i<width-2 and j<height-2:
					if array[i][j]!=null and array[i+1][j]!=null and array[i+2][j]!=null and array[i][j+1]!=null and array[i][j+2]!=null:
						if array[i][j].color == current_color and array[i+1][j].color == current_color and array[i+2][j].color == current_color and array[i][j+1].color == current_color and array[i][j+2].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,0)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("findandspawnadjacentC")
				if i>1 and j<height-2:
					if array[i][j]!=null and array[i-1][j]!=null and array[i-2][j]!=null and array[i][j+1]!=null and array[i][j+2]!=null:
						if array[i][j].color == current_color and array[i-1][j].color == current_color and array[i-2][j].color == current_color and array[i][j+1].color == current_color and array[i][j+2].color == current_color:
							var piece=array[i][j]
							create_bomb(piece,0)
							if_not_has_add_to_array(Vector2(i,j),newly_made_specials)
							print("findandspawnadjacentD")
	print("newly_made_specials",newly_made_specials)
	print("threeplusone",three_plus_one)
	if query:
		find_matches(false,array,true)
		if newly_made_specials!=null:
			bombs_were_found_after_swap=true
		else:
			bombs_were_found_after_swap=false
			
	else:
		if swap_query:
			find_matches(false,array,false,true)
		else:
			find_matches()
	emit_signal("found_and_spawned_bombs")

func create_bomb(piece,type):
	piece.matched=false
	var pos=pixel_to_grid(piece.position.x,piece.position.y)
	damage_special(pos.x,pos.y)
	emit_signal("check_goal",piece.color)
	change_bomb(type,piece)

func change_bomb(type,piece):
	#adjacent-row-col-color
	var current_color = piece.color
	var release_grid
	var wait_time=0
	await found_and_spawned_bombs
	
	#find out whether special is created after switch or after refill
	if bombs_were_found_after_swap:
		release_grid=pixel_to_grid(release_piece.position.x,release_piece.position.y)
		wait_time=0
		print("after_swap")
	else:
		release_grid=Vector2(newly_made_specials[0].x,newly_made_specials[0].y)
		print("after_refill")
		await refill_is_done
		wait_time=.3
	
	if type ==0 : #adjacent
		SoundManager.play_fixed_sound("adjacent_bomb_created")
		make_bomb_spawn_effects(current_color,release_grid.x,release_grid.y)
		await get_tree().create_timer(wait_time).timeout
		make_particle_effect(release_grid.x,release_grid.y)
		if piece!=null:
			piece.make_adjacent_bomb()
	if type ==1 : #column
		SoundManager.play_fixed_sound("colrow_bomb_created")
		make_bomb_spawn_effects(current_color,release_grid.x,release_grid.y)
		await get_tree().create_timer(wait_time).timeout
		make_particle_effect(release_grid.x,release_grid.y)
		if piece!=null:
			piece.make_column_bomb()
		print("MADECOLUMNBOMB1482")
	if type ==2 : #row
		SoundManager.play_fixed_sound("colrow_bomb_created")
		make_bomb_spawn_effects(current_color,release_grid.x,release_grid.y)
		await get_tree().create_timer(wait_time).timeout
		make_particle_effect(release_grid.x,release_grid.y)
		if piece!=null:
			piece.make_row_bomb()
	if type ==3 : #color
		SoundManager.play_fixed_sound("color_bomb_created")
		make_particle_effect(release_grid.x,release_grid.y)
		await get_tree().create_timer(wait_time).timeout
		make_particle_effect(release_grid.x,release_grid.y)
		if piece!=null:
			piece.make_color_bomb()
		
func destroy_adjacent_for_coloradjacent(i,j,current_color):
	print("destroy_adj_for_coloradj")
	if array[i][j].matched==true:
		make_bomb_explode_effects("adjacent",current_color,i,j)
		shock_effect(i,j)
		array[i][j].queue_free()
		array[i][j]=null
		effect_animator(current_color,i,j)
		make_particle_effect(i,j)
		emit_signal("shake_harder")
		for column in range(-1,+2):
			for row in range(-1,2):
					if is_in_grid(Vector2(column+i,row+j)):
						if array[column+i][row+j]!=null and !is_piece_sinker(column+i,row+j) and array[column+i][row+j].matched==false :
							var piece=array[column+i][row+j]
							if piece.is_special!=true:
								current_color=array[column+i][row+j].color
								emit_signal("check_goal",array[column+i][row+j].color)
								damage_special(column+i,row+j)
								array[column+i][row+j].queue_free()
								array[column+i][row+j]=null
								effect_animator(current_color,column+i,row+j)
								make_particle_effect(column+i,row+j)
								emit_signal("update_score",piece_value*streak)
								var amount_to_change=piece_value*streak
								current_score += amount_to_change
								emit_signal("update_current_score",current_score)
								await get_tree().create_timer(0.10).timeout
							else:
								destroy_special_matched(column+i,row+j)
		print("destroy_adjacent_for_coloradjacent")
		
func destroy_adjacent_for_adjacentadjacent(i,j,current_color,removal_query=false):
	make_bomb_explode_effects("big_adjacent",current_color,i,j)
	make_particle_effect(i,j)
	emit_signal("shake_harder")
	for column in range(-2,+3):
		for row in range(-2,+3):
				if is_in_grid(Vector2(column+i,row+j)):
					if array[column+i][row+j]!=null and !is_piece_sinker(column+i,row+j) and array[column+i][row+j].matched==false :
						var piece=array[column+i][row+j]
						if piece.is_special!=true:
							if removal_query:
								current_color=array[column+i][row+j].color
								emit_signal("check_goal",array[column+i][row+j].color)
								damage_special(column+i,row+j)
								array[column+i][row+j].queue_free()
								array[column+i][row+j]=null
								effect_animator(current_color,column+i,row+j)
								make_particle_effect(column+i,row+j)
								emit_signal("update_score",piece_value*streak)
								var amount_to_change=piece_value*streak
								current_score += amount_to_change
								emit_signal("update_current_score",current_score)
								await get_tree().create_timer(.010).timeout
							else:
								if piece.is_pseudo_adjacent_bomb!=true:
									current_color=array[column+i][row+j].color
									emit_signal("check_goal",array[column+i][row+j].color)
									damage_special(column+i,row+j)
									array[column+i][row+j].queue_free()
									array[column+i][row+j]=null
									effect_animator(current_color,column+i,row+j)
									make_particle_effect(column+i,row+j)
									emit_signal("update_score",piece_value*streak)
									var amount_to_change=piece_value*streak
									current_score += amount_to_change
									emit_signal("update_current_score",current_score)
									await get_tree().create_timer(.010).timeout
						else:
							destroy_special_matched(column+i,row+j)
	print("destroy_adjacent_for_adjacentadjacent")
	
func destroy_special_matched(i,j):
	var piece=array[i][j]
	if piece!=null and piece.is_pseudo_adjacent_bomb!=true:
		var current_color=array[i][j].color
		if piece.matched==true:
			if piece.is_row_bomb:
				destroy_all_in_row(i,j,current_color)
				array[i][j].queue_free()
				array[i][j]=null
			if piece.is_column_bomb:
				destroy_all_in_column(i,j,current_color)
				array[i][j].queue_free()
				array[i][j]=null
			if piece.is_adjacent_bomb:
				destroy_specials_adjacent(i,j,current_color)
				array[i][j].queue_free()
				array[i][j]=null
			if piece.is_fish():
				array[i][j].queue_free()
				array[i][j]=null
				
func destroy_all_in_row(i,j,current_color,dont_collapse_query=false):
	print("destroyed_all_in_row")
	effect_animator(current_color,i,j)
	make_particle_effect(i,j)
	make_bomb_explode_effects("row",current_color,i,j)
	var x=0
	var y=0
	for w in width:
		if i+x>=0 and i+x<width:
			if array[i+x][j]!=null:
				if array[i+x][j].is_special!=true:
					if array[i+x][j].color=="blocker":
						return
					else:
						var x_color = array[i+x][j].color
						effect_animator(x_color,i+x,j)
						make_particle_effect(i+x,j)
						emit_signal("check_goal",array[i+x][j].color)
						array[i+x][j].queue_free()
						array[i+x][j]=null
						emit_signal("update_score",piece_value*streak)
						var amount_to_change=piece_value*streak
						current_score += amount_to_change
						emit_signal("update_current_score",current_score)
						damage_special(i+x,j,true)
						print("A")
						
		if i+y>=0 and i+y<width:
			if array[i+y][j]!=null:
				if array[i+y][j].is_special!=true:
					if array[i+y][j].color=="blocker":
						return
					else:
						var y_piece = array[i+y][j]
						var y_color =y_piece.color
						effect_animator(y_color,i+y,j)
						make_particle_effect(i+y,j)
						emit_signal("check_goal",array[i+y][j].color)
						array[i+y][j].queue_free()
						array[i+y][j]=null
						emit_signal("update_score",piece_value*streak)
						var amount_to_change=piece_value*streak
						current_score += amount_to_change
						emit_signal("update_current_score",current_score)
						damage_special(i+y,j,true)
						print("B")
				else:
					if array[i+y][j].is_column_bomb:
						destroy_all_in_column(i+y,j,array[i+y][j].color)
						if array[i+y][j]!=null:
							array[i+y][j].queue_free()
							array[i+y][j]=null
							print("destroy_row_col_bomb2")
					if array[i+y][j].is_adjacent_bomb:
						destroy_specials_adjacent(i+y,j,current_color)
						if array[i+y][j]!=null:
							array[i+y][j].queue_free()
							array[i+y][j]=null
		x+=1
		y-=1
		await get_tree().create_timer(.020).timeout
		if dont_collapse_query:
			pass
		else:
			await get_tree().create_timer(.2).timeout
			collapse_columns()
		
		
func destroy_all_in_column(i,j,current_color):
	print("destroyed_all_in_column")
	effect_animator(current_color,i,j)
	make_particle_effect(i,j)
	make_bomb_explode_effects("column",current_color,i,j)
	var x=0
	var y=0
	for w in height:
		if j+x>=0 and j+x<height:
			if array[i][j+x]!=null:
				if array[i][j+x].is_special!=true:
					if array[i][j+x].color=="blocker":
						return
					else:
						var x_color = array[i][j+x].color
						effect_animator(x_color,i,j+x)
						make_particle_effect(i,j+x)
						emit_signal("check_goal",array[i][j+x].color)
						array[i][j+x].queue_free()
						array[i][j+x]=null
						emit_signal("update_score",piece_value*streak)
						var amount_to_change=piece_value*streak
						current_score += amount_to_change
						emit_signal("update_current_score",current_score)
						damage_special(i,j+x,true)
						print("C")
				else:
					destroy_specials()
					pass
					
		if j+y>=0 and j+y<height:
			if array[i][j+y]!=null:
				if array[i][j+y].is_special!=true:
					if array[i][j+y].color=="blocker":
						return
					else:
						var y_color = array[i][j+y].color
						effect_animator(y_color,i,j+y)
						make_particle_effect(i,j+y)
						emit_signal("check_goal",array[i][j+y].color)
						array[i][j+y].queue_free()
						array[i][j+y]=null
						emit_signal("update_score",piece_value*streak)
						var amount_to_change=piece_value*streak
						current_score += amount_to_change
						emit_signal("update_current_score",current_score)
						damage_special(i,j+y,true)
						print("D")
				else:
					destroy_specials()
					pass
		x+=1
		y-=1
		await get_tree().create_timer(.020).timeout
		
	await get_tree().create_timer(.2).timeout
	collapse_columns()
	
func destroy_specials(colrowquery=false):
	var x=0
	var y=0
	for i in width:
		for j in height:
			if array[i][j]!=null :
				var piece=array[i][j]
				var current_color = array[i][j].color
				if array[i][j].is_special==true and piece.matched==true:
					
					if array[i][j]!=null and array[i][j].is_column_bomb:
						array[i][j].queue_free()
						array[i][j]=null
						effect_animator(current_color,i,j)
						make_particle_effect(i,j)
						make_bomb_explode_effects("column",current_color,i,j)
						print("destroy_specials_col_bomb_detected")
						
						for w in height:
							if j+x>=0 and j+x<height:
								if array[i][j+x]!=null:
									if array[i][j+x].is_special!=true:
										if array[i][j+x].color=="blocker":
											return
										else:
											var x_color = array[i][j+x].color
											effect_animator(x_color,i,j+x)
											make_particle_effect(i,j+x)
											emit_signal("check_goal",array[i][j+x].color)
#											damage_special2(i,j+x)
											array[i][j+x].queue_free()
											array[i][j+x]=null
											emit_signal("update_score",piece_value*streak)
											var amount_to_change=piece_value*streak
											current_score += amount_to_change
											emit_signal("update_current_score",current_score)
#									else:
#										if array[i][j+x]!=null and array[i][j+x].is_row_bomb and array[i][j+x].is_adjacent_bomb!=true:
#											destroy_specials_row(i,j+x)
											
							if j+y>=0 and j+y<height:
								if array[i][j+y]!=null:
									if array[i][j+y].is_special!=true:
										if array[i][j+y].color=="blocker":
											return
										else:
											var y_color = array[i][j+y].color
											effect_animator(y_color,i,j+y)
											make_particle_effect(i,j+y)
											emit_signal("check_goal",array[i][j+y].color)
#											damage_special2(i,j+y)
											array[i][j+y].queue_free()
											array[i][j+y]=null
											emit_signal("update_score",piece_value*streak)
											var amount_to_change=piece_value*streak
											current_score += amount_to_change
											emit_signal("update_current_score",current_score)
#									else:
#										if array[i][j+y]!=null and array[i][j+y].is_row_bomb and array[i][j+y].is_adjacent_bomb!=true:
#											destroy_specials_row(i,j+y)
											
							x+=1
							y-=1
							await get_tree().create_timer(.020).timeout
#						get_parent().get_node("collapse_timer").start()
						
					if array[i][j]!=null and array[i][j].is_row_bomb:
						array[i][j].queue_free()
						array[i][j]=null
						effect_animator(current_color,i,j)
						make_particle_effect(i,j)
						make_bomb_explode_effects("row",current_color,i,j)
						print("destroy_specials_row_bomb_detected")
						
						for w in width:
							if i+x>=0 and i+x<width:
								if array[i+x][j]!=null:
									if array[i+x][j].is_special!=true:
										if array[i+x][j].color=="blocker":
											return
										else:
											var x_color = array[i+x][j].color
											effect_animator(x_color,i+x,j)
											make_particle_effect(i+x,j)
											emit_signal("check_goal",array[i+x][j].color)
#											damage_special2(i+x,j)
											array[i+x][j].queue_free()
											array[i+x][j]=null
											emit_signal("update_score",piece_value*streak)
											var amount_to_change=piece_value*streak
											current_score += amount_to_change
											emit_signal("update_current_score",current_score)
	#									else:
	#										if array[i+x][j]!=null and array[i+x][j].is_column_bomb and array[i+x][j].is_adjacent_bomb!=true:
	#											destroy_specials_col(i+x,j)
											
							if i+y>=0 and i+y<width:
								if array[i+y][j]!=null:
									if array[i+y][j].is_special!=true:
										if array[i+y][j].color=="blocker":
											return
										else:
											var y_piece = array[i+y][j]
											var y_color =y_piece.color
											effect_animator(y_color,i+y,j)
											make_particle_effect(i+y,j)
											emit_signal("check_goal",array[i+y][j].color)
#											damage_special2(i+y,j)
											array[i+y][j].queue_free()
											array[i+y][j]=null
											emit_signal("update_score",piece_value*streak)
											var amount_to_change=piece_value*streak
											current_score += amount_to_change
											emit_signal("update_current_score",current_score)
	#									else:
	#										if array[i+y][j]!=null and array[i+y][j].is_column_bomb and array[i+y][j].is_adjacent_bomb!=true:
	#											destroy_specials_col(i+y,j)
											
							x+=1
							y-=1
							await get_tree().create_timer(.020).timeout
							
	print("destroy_specials")
	if colrowquery:
		destroy_matched(true)
	else:
		destroy_matched()

func destroy_specials_adjacent(i,j,current_color):
	if array[i][j].matched==true:
		make_bomb_explode_effects("adjacent",current_color,i,j)
		shock_effect(i,j)
		match_and_add_to_matches(i,j)
		effect_animator(current_color,i,j)
		make_particle_effect(i,j)
		emit_signal("shake_harder")
		for column in range(-1,+2):
			for row in range(-1,2):
				if i!=0 and j!=0:
					if is_in_grid(Vector2(column+i,row+j)):
						if array[column+i][row+j]!=null and !is_piece_sinker(column+i,row+j) and array[column+i][row+j].matched==false :
							current_color=array[column+i][row+j].color
							emit_signal("check_goal",array[column+i][row+j].color)
							damage_special(column+i,row+j)
							array[column+i][row+j].queue_free()
							array[column+i][row+j]=null
							effect_animator(current_color,column+i,row+j)
							make_particle_effect(column+i,row+j)
							emit_signal("update_score",piece_value*streak)
							var amount_to_change=piece_value*streak
							current_score += amount_to_change
							emit_signal("update_current_score",current_score)
							await get_tree().create_timer(0.05).timeout
		print("destroy_specials_adjacent")

func destroy_specials_for_colrowcolor(colrowquery=false):
	var x=0
	var y=0
	for i in width:
		for j in height:
			if array[i][j]!=null :
#				var piece=array[i][j]
				var current_color = array[i][j].color
				if array[i][j].is_special==true:
					
					if array[i][j]!=null and array[i][j].is_column_bomb and array[i][j].matched==true:
						array[i][j].queue_free()
						array[i][j]=null
						effect_animator(current_color,i,j)
						make_particle_effect(i,j)
						make_bomb_explode_effects("column",current_color,i,j)
						
						for w in height:
							if j+x>=0 and j+x<height:
								if array[i][j+x]!=null:
									if array[i][j+x].is_adjacent_bomb!=true and array[i][j+x].is_row_bomb!=true:
										var x_color = array[i][j+x].color
										effect_animator(x_color,i,j+x)
										make_particle_effect(i,j+x)
										emit_signal("check_goal",array[i][j+x].color)
										damage_special2(i,j+x)
										array[i][j+x].queue_free()
										array[i][j+x]=null
										emit_signal("update_score",piece_value*streak)
										var amount_to_change=piece_value*streak
										current_score += amount_to_change
										emit_signal("update_current_score",current_score)
									else:
										if array[i][j+x]!=null and array[i][j+x].is_row_bomb and array[i][j+x].is_adjacent_bomb!=true:
											destroy_specials_row(i,j+x)
											print("DSCRC"+str(j+x))
											
							if j+y>=0 and j+y<height:
								if array[i][j+y]!=null:
									if  array[i][j+y].is_adjacent_bomb!=true and array[i][j+y].is_row_bomb!=true:
										var y_color = array[i][j+y].color
										effect_animator(y_color,i,j+y)
										make_particle_effect(i,j+y)
										emit_signal("check_goal",array[i][j+y].color)
										damage_special2(i,j+y)
										array[i][j+y].queue_free()
										array[i][j+y]=null
										emit_signal("update_score",piece_value*streak)
										var amount_to_change=piece_value*streak
										current_score += amount_to_change
										emit_signal("update_current_score",current_score)
									else:
										if array[i][j+y]!=null and array[i][j+y].is_row_bomb and array[i][j+y].is_adjacent_bomb!=true:
											destroy_specials_row(i,j+y)
											print("DSCRC"+str(j+x))
											
							x+=1
							y-=1
							await get_tree().create_timer(.020).timeout
						get_parent().get_node("collapse_timer").start()
						
					if array[i][j]!=null and array[i][j].is_row_bomb and array[i][j].matched==true:
						array[i][j].queue_free()
						array[i][j]=null
						effect_animator(current_color,i,j)
						make_particle_effect(i,j)
						make_bomb_explode_effects("row",current_color,i,j)
						
						for w in width:
							if i+x>=0 and i+x<width:
								if array[i+x][j]!=null:
									if array[i+x][j].is_adjacent_bomb!=true and array[i+x][j].is_column_bomb!=true:
										var x_color = array[i+x][j].color
										effect_animator(x_color,i+x,j)
										make_particle_effect(i+x,j)
										emit_signal("check_goal",array[i+x][j].color)
										damage_special2(i+x,j)
										array[i+x][j].queue_free()
										array[i+x][j]=null
										emit_signal("update_score",piece_value*streak)
										var amount_to_change=piece_value*streak
										current_score += amount_to_change
										emit_signal("update_current_score",current_score)
									else:
										if array[i+x][j]!=null and array[i+x][j].is_column_bomb and array[i+x][j].is_adjacent_bomb!=true:
											destroy_specials_column(i+x,j)
											
							if i+y>=0 and i+y<width:
								if array[i+y][j]!=null:
									if array[i+y][j].is_adjacent_bomb!=true and array[i+y][j].is_column_bomb!=true:
										var y_piece = array[i+y][j]
										var y_color =y_piece.color
										effect_animator(y_color,i+y,j)
										make_particle_effect(i+y,j)
										emit_signal("check_goal",array[i+y][j].color)
										damage_special2(i+y,j)
										array[i+y][j].queue_free()
										array[i+y][j]=null
										emit_signal("update_score",piece_value*streak)
										var amount_to_change=piece_value*streak
										current_score += amount_to_change
										emit_signal("update_current_score",current_score)
									else:
										if array[i+y][j]!=null and array[i+y][j].is_column_bomb and array[i+y][j].is_adjacent_bomb!=true:
											destroy_specials_column(i+y,j)
											
							x+=1
							y-=1
							await get_tree().create_timer(.020).timeout
						get_parent().get_node("collapse_timer").start()
							
					if array[i][j]!=null and array[i][j].is_adjacent_bomb:
						if array[i][j].matched==true:
							make_bomb_explode_effects("adjacent",current_color,i,j)
							shock_effect(i,j)
							emit_signal("shake_harder")
							effect_animator(current_color,i,j)
							make_particle_effect(i,j)
							print("destroy_specials_for_colrowcolor_adjacent")
							
	print("destroy_special")
	if colrowquery:
		destroy_matched(true)
	else:
		destroy_matched()

func destroy_specials_row(i,j):
	var x=0
	var y=0
	if array[i][j]!=null:
		var current_color = array[i][j].color
		array[i][j].queue_free()
		array[i][j]=null
		effect_animator(current_color,i,j)
		make_particle_effect(i,j)
		make_bomb_explode_effects("row",current_color,i,j)
		print('destroy_specials_row')
	
	for w in width:
		if i+x>=0 and i+x<width:
			damage_special(i+x,j,true)
			if array[i+x][j]!=null:
				if array[i+x][j].color=="blocker":
						return
				if array[i+x][j].is_special==true:
					
					if array[i+x][j]!=null:
						if array[i+x][j].is_column_bomb:
							match_all_in_column(i+x,j,array[i+x][j].color)
							
					if array[i+x][j]!=null:
						if array[i+x][j].is_row_bomb:
							match_all_in_row(i+x,j,array[i+x][j].color)
							
					if array[i+x][j]!=null:
						if array[i+x][j].is_adjacent_bomb:
							find_adjacent_pieces(i+x,j,array[i+x][j].color)
				else:
					var x_color = array[i+x][j].color
					effect_animator(x_color,i+x,j)
					make_particle_effect(i+x,j)
					emit_signal("check_goal",array[i+x][j].color)
					array[i+x][j].queue_free()
					array[i+x][j]=null
					emit_signal("update_score",piece_value*streak)
					var amount_to_change=piece_value*streak
					current_score += amount_to_change
					emit_signal("update_current_score",current_score)
					
		if i+y>=0 and i+y<width:
			damage_special(i+y,j,true)
			if array[i+y][j]!=null:
				if array[i+y][j].color=="blocker":
					return
				if array[i+y][j].is_special==true:
					
					if array[i+y][j]!=null:
						if array[i+y][j].is_column_bomb:
							match_all_in_column(i+y,j,array[i+y][j].color)
					
					if array[i+y][j]!=null:
						if array[i+y][j].is_row_bomb:
							match_all_in_row(i+y,j,array[i+y][j].color)
							
					if array[i+y][j]!=null:
						if array[i+y][j].is_adjacent_bomb:
							find_adjacent_pieces(i+y,j,array[i+y][j].color)
				
				else:
					var y_piece = array[i+y][j]
					var y_color =y_piece.color
					effect_animator(y_color,i+y,j)
					make_particle_effect(i+y,j)
					emit_signal("check_goal",array[i+y][j].color)
					array[i+y][j].queue_free()
					array[i+y][j]=null
					emit_signal("update_score",piece_value*streak)
					var amount_to_change=piece_value*streak
					current_score += amount_to_change
					emit_signal("update_current_score",current_score)
					damage_special(i+y,j,true)
					
		x+=1
		y-=1
		await get_tree().create_timer(.020).timeout
	get_parent().get_node("collapse_timer").start()

func destroy_specials_column(i,j):
	var x=0
	var y=0
	if array[i][j]!=null:
		var current_color = array[i][j].color
		array[i][j].queue_free()
		array[i][j]=null
		effect_animator(current_color,i,j)
		make_particle_effect(i,j)
		make_bomb_explode_effects("column",current_color,i,j)
		print('destroy_specials_col')
	
	for w in height:
		if j+x>=0 and j+x<height:
			damage_special(i,j+x,true)
			if array[i][j+x]!=null:
				if array[i][j+x].color=="blocker":
						return
				if array[i][j+x].is_special==true and array[i][j+x].matched==false:
					var piece=array[i][j+x]
					if piece.is_column_bomb:
#						destroy_specials_column(i,j)
						match_all_in_column(i,j+x,array[i][j+x].color)
					if piece.is_row_bomb:
#						destroy_specials_row(i,j)
						match_all_in_row(i,j+x,array[i][j+x].color)
					if piece.is_adjacent_bomb:
						find_adjacent_pieces(i,j+x,array[i][j+x].color)
				else:
					var x_color = array[i][j+x].color
					effect_animator(x_color,i,j+x)
					make_particle_effect(i,j+x)
					emit_signal("check_goal",array[i][j+x].color)
					array[i][j+x].queue_free()
					array[i][j+x]=null
					emit_signal("update_score",piece_value*streak)
					var amount_to_change=piece_value*streak
					current_score += amount_to_change
					emit_signal("update_current_score",current_score)
					
		if j+y>=0 and j+y<height:
			damage_special(i,j+y,true)
			if array[i][j+y]!=null:
				if array[i][j+y].color=="blocker":
						return
				if array[i][j+y].is_special==true and array[i][j+y].matched==false:
					var piece=array[i][j+y]
					if piece.is_column_bomb:
#						destroy_specials_column(i,j)
						match_all_in_column(i,j+y,array[i][j+y].color)
					if piece.is_row_bomb:
#						destroy_specials_row(i,j)
						match_all_in_row(i,j+y,array[i][j+y].color)
					if piece.is_adjacent_bomb:
						find_adjacent_pieces(i,j+y,array[i][j+y].color)
				else:
					var y_color = array[i][j+y].color
					effect_animator(y_color,i,j+y)
					make_particle_effect(i,j+y)
					emit_signal("check_goal",array[i][j+y].color)
					array[i][j+y].queue_free()
					array[i][j+y]=null
					emit_signal("update_score",piece_value*streak)
					var amount_to_change=piece_value*streak
					current_score += amount_to_change
					emit_signal("update_current_score",current_score)
				
		x+=1
		y-=1
		await get_tree().create_timer(.020).timeout
	get_parent().get_node("collapse_timer").start()

signal destroy_matched_finished
func destroy_matched(colrowquery=false):
	var was_matched =false
	for i in width:
		for j in height:
			if array[i][j]!=null:
				var piece=array[i][j]
				var current_color = array[i][j].color
				if piece.is_special==false and piece.is_pseudo_adjacent_bomb!=true :
					if piece.matched==true:
						effect_animator(current_color,i,j)
						make_particle_effect(i,j)
						emit_signal("check_goal",array[i][j].color)
						emit_signal("shake")
						damage_special(i,j)
						was_matched=true
						array[i][j].queue_free()
						array[i][j]=null
						emit_signal("update_score",piece_value*streak)
						var amount_to_change=piece_value*streak
						current_score += amount_to_change
						emit_signal("update_current_score",current_score)
						await get_tree().create_timer(.010).timeout
				else:
					if piece.matched==true and piece.is_pseudo_adjacent_bomb!=true:
						if piece!=null:
							if piece!=null:
								if piece.is_row_bomb:
										destroy_all_in_row(i,j,current_color)
										array[i][j].queue_free()
										array[i][j]=null
							if piece!=null:
								if piece.is_column_bomb:
									destroy_all_in_column(i,j,current_color)
									array[i][j].queue_free()
									array[i][j]=null
							if piece!=null:
								if piece.is_adjacent_bomb:
									destroy_specials_adjacent(i,j,current_color)
									array[i][j].queue_free()
									array[i][j]=null
							if piece!=null:
								if piece.is_pseudo_adjacent_bomb:
									destroy_adjacent_for_adjacentadjacent(i,j,current_color)
									array[i][j].queue_free()
									array[i][j]=null
							if piece!=null:
								if piece.is_color_bomb:
									array[i][j].queue_free()
									array[i][j]=null
							if piece!=null:
								if piece.is_fish:
									array[i][j].queue_free()
									array[i][j]=null
	if was_matched==true:
		get_parent().get_node("collapse_timer").start()
	if colrowquery==true:
		pass
	else:
		current_matches.clear()
	print("destroymatched")
	emit_signal("destroy_matched_finished")

#when swapped concrete damages around it but bombs dont
func damage_special(column,row,bomb_query=false):
	if bomb_query:
		damage_concrete(column,row)
	else:
		damage_lock(column,row)
		damage_ice(column,row)
		check_concrete(column,row)
		check_slime(column,row)
		check_marmalade(column,row)
		check_swirl(column,row)
		check_blocker(column,row)

#stop blockers from getting yeeted and deleted with colrow bombs
func damage_special2(column,row):
	damage_lock(column,row)
	damage_ice(column,row)
	check_concrete(column,row)
	check_slime(column,row)
	check_marmalade(column,row)
	check_swirl(column,row)

func damage_marmalade(column,row):
	if marmalade_pieces.size()!=0:
		if marmalade_pieces[column][row] !=null:
			SoundManager.play_fixed_sound("damage_marmalade")
			Input.vibrate_handheld(100)
			effect_animator("marmalade",column,row)
			marmalade_pieces[column][row].take_damage(1)
			marmalade_pieces[column][row].text_setter()
			if marmalade_pieces[column][row].health<=0 :
				marmalade_pieces[column][row].queue_free()
				marmalade_pieces[column][row]=null
				position=Vector2(column,row)
				remove_marmalade(position)
				emit_signal("break_marmalade","marmalade")
				effect_animator("marmalade",column,row)

func damage_swirl(column,row):
	if swirl_pieces.size()!=0:
		if swirl_pieces[column][row] !=null:
			SoundManager.play_fixed_sound("damage_swirl")
			Input.vibrate_handheld(100)
			swirl_pieces[column][row].take_damage(1)
			if swirl_pieces[column][row].health<=0 :
				swirl_pieces[column][row].queue_free()
				swirl_pieces[column][row]=null
				position=Vector2(column,row)
				remove_swirl(position)
				emit_signal("break_swirl","swirl")
				effect_animator("swirl",column,row)

func damage_concrete(column,row):
	if concrete_pieces.size()!=0:
		if concrete_pieces[column][row] !=null:
			SoundManager.play_tracked_sound("damage_concrete")
			Input.vibrate_handheld(100)
			effect_animator("sinker",column,row)
			concrete_pieces[column][row].take_damage(1)
			concrete_pieces[column][row].text_setter()
			if concrete_pieces[column][row].health<=0 :
				concrete_pieces[column][row].queue_free()
				concrete_pieces[column][row]=null
				position=Vector2(column,row)
				remove_concrete(position)
				emit_signal("break_concrete","concrete")
				no_longer_restricted_spaces.append(Vector2(column,row))
				print('no_longer_restricted_spaces: ',no_longer_restricted_spaces)
				effect_animator("concrete",column,row)

func damage_slime(column,row):
	if slime_pieces.size() !=0 :
		if slime_pieces[column][row] !=null :
			SoundManager.play_fixed_sound("damage_slime")
			Input.vibrate_handheld(100)
			slime_pieces[column][row].take_damage(1)
			if slime_pieces[column][row].health<=0 :
				slime_pieces[column][row].queue_free()
				slime_pieces[column][row]=null
				position=Vector2(column,row)
				remove_slime(position)
				emit_signal("break_slime","slime")
				effect_animator("slime",column,row)

func damage_ice(column,row):
	if ice_pieces.size() !=0 :
		if ice_pieces[column][row] !=null :
			SoundManager.play_fixed_sound("damage_ice")
			Input.vibrate_handheld(100)
			effect_animator("ice",column,row)
			ice_pieces[column][row].take_damage(1)
			ice_pieces[column][row].text_setter()
			if ice_pieces[column][row].health<=0 :
				ice_pieces[column][row].queue_free()
				ice_pieces[column][row]=null
				emit_signal("break_ice","ice")
				effect_animator("ice",column,row)

func ice_counter(column,row):
	var tally=0
	for i in ice_pieces.size():
		if ice_pieces[i]==Vector2(column,row):
			tally+=1
	return tally

func damage_lock(column,row):
	if lock_pieces.size() !=0 :
		if lock_pieces[column][row]!=null :
			SoundManager.play_fixed_sound("damage_lock")
			Input.vibrate_handheld(100)
			lock_pieces[column][row].take_damage(1)
			if lock_pieces[column][row].health<=0 :
				lock_pieces[column][row].queue_free()
				lock_pieces[column][row]=null
				remove_lock(Vector2(column,row))
				emit_signal("break_lock","lock")
				effect_animator("lock",column,row) 


func remove_lock(place):
	for i in range(lock_spaces.size()-1,-1,-1) :
		if lock_spaces[i]==place :
			lock_spaces.remove_at(i)

func get_bomb_pieces(query=false):
	for i in width :
		for j in height :
			if array[i][j]!=null:
				if array[i][j].matched==true :
					if array[i][j].is_column_bomb :
						var color_of_bomb=array[i][j].color
						destroy_specials_column(i,j)
#						match_all_in_column(i,j,color_of_bomb)
					if array[i][j]!=null:
						if array[i][j].is_row_bomb :
							var color_of_bomb=array[i][j].color
							destroy_specials_row(i,j)
#							match_all_in_row(i,j,color_of_bomb)
					if array[i][j]!=null:
						if array[i][j].is_adjacent_bomb :
							var color_of_bomb=array[i][j].color
							find_adjacent_pieces(i,j,color_of_bomb)
	if query:
		print("bombsgetgot")
		destroy_specials(true)
	else:
#		await get_tree().create_timer(.1).timeout
		newly_made_specials.clear()
		print("cleared")
		destroy_specials()
	
#matches every piece of certain color in the board
func match_color(color):
	SoundManager.play_fixed_sound("color_bomb_explode")
	Input.vibrate_handheld(100)
	for i in width:
		for j in height :
			if array[i][j]!=null and !is_piece_sinker(i,j) and !restricted_fill(Vector2(i,j)):
				if array[i][j].color==color and array[i][j].matched==false:
					if array[i][j]!=null:
						if array[i][j].is_column_bomb :
							destroy_specials_column(i,j)
#							match_all_in_column(i,j,color)
					if array[i][j]!=null:
							destroy_specials_row(i,j)
#							match_all_in_row(i,j,color)
					if array[i][j]!=null:
						if array[i][j].is_adjacent_bomb:
							find_adjacent_pieces(i,j,color)
					match_and_add_to_matches(i,j)

func match_all_in_row(column,row,color_of_bomb):
	emit_signal("check_goal","row")
	emit_signal("check_goal","striped")
	for i in width :
		if array[i][row]!=null and !is_piece_sinker(i,row) and array[i][row].matched==false:
			
			if array[i][row]!=null and array[i][row].matched==false:
				if array[i][row].is_column_bomb:
					array[i][row].matched=true
					match_all_in_column(i,row,color_of_bomb)
					
			if array[i][row]!=null and array[i][row].matched==false:
				if array[i][row].is_adjacent_bomb:
					find_adjacent_pieces(i,row,color_of_bomb)
					
			if array[i][row]!=null and array[i][row].matched==false:
				if array[i][row].is_color_bomb:
					match_color(color_of_bomb)
				
	destroy_specials_row(column,row)
	print("MAIR",row)

func match_all_in_column(column,row,color_of_bomb) :
	print('match_all_in_column')
	emit_signal("check_goal","column")
	emit_signal("check_goal","striped")
	for i in height :
		if array[column][i] !=null and !is_piece_sinker(column,i) and array[column][i].matched==false :
			
			if array[column][i]!=null and array[column][i].matched==false:
				if array[column][i].is_row_bomb:
					array[column][i].matched=true
					match_all_in_row(i,row,color_of_bomb)
				
			if array[column][i]!=null and array[column][i].matched==false:
				if array[column][i].is_adjacent_bomb:
					find_adjacent_pieces(column,i,color_of_bomb)
					
			if array[column][i]!=null and array[column][i].matched==false:
				if array[column][i].is_color_bomb:
					match_color(color_of_bomb)
				
	destroy_specials_column(column,row)
	print('MAIC',column)

func find_adjacent_pieces(column,row,color_of_bomb):
	emit_signal("check_goal","adjacent")
	emit_signal("check_goal","striped")
	#-1,0,1
	for i in range(-1,+2):
		for j in range(-1,2):
			if is_in_grid(Vector2(column+i,row+j)):
				if array[column+i][row+j]!=null and !is_piece_sinker(column+i,row+j) and array[column+i][row+j].matched==false :
					if array[column+i][row+j].is_row_bomb:
						match_all_in_row(i,j,color_of_bomb)
					if array[column+i][row+j].is_column_bomb:
						match_all_in_column(i,j,color_of_bomb)
					if array[column+i][row+j].is_color_bomb:
						match_color(color_of_bomb)
	destroy_specials_adjacent(column,row,color_of_bomb)

func clear_board():
	for i in width :
		for j in height :
			print(array[i][j])
			if array[i][j]!=null and !is_piece_sinker(i,j):
				if check_if_blocker(i,j):
					damage_special(i,j)
				else:
					match_and_add_to_matches(i,j)

func check_if_blocker(column,row):
#	print(column,row)
	for i in concrete_spaces.size():
		if concrete_spaces[i]!=null:
			if concrete_spaces[i]==Vector2(column,row):
				return true
				
#	for i in ice_spaces.size():
#		if ice_spaces[i]!=null:
#			if ice_spaces[i]==Vector2(column,row):
#				return true
#
#	for i in marmalade_spaces.size():
#		if marmalade_spaces[i]!=null:
#			if marmalade_spaces[i]==Vector2(column,row):
#				return true
#
#	for i in lock_spaces.size():
#		if lock_spaces[i]!=null:
#			if lock_spaces[i]==Vector2(column,row):
#				return true
				
	return false

func check_marmalade(column,row):
	if marmalade_spaces!=null:
		#check right
		if column<width-1 :
			damage_marmalade(column+1,row)
		#check left
		if column>0 :
			damage_marmalade(column-1,row)
		#check up 
		if row<height-1 :
			damage_marmalade(column,row+1)
		#check down
		if row>0 :
			damage_marmalade(column,row-1)

func check_swirl(column,row):
	if swirl_spaces!=null:
		#check right
		if column<width-1 :
			damage_swirl(column+1,row)
		#check left
		if column>0 :
			damage_swirl(column-1,row)
		#check up 
		if row<height-1 :
			damage_swirl(column,row+1)
		#check down
		if row>0 :
			damage_swirl(column,row-1)

func check_concrete(column,row):
	if concrete_spaces!=null:
		#check right
		if column<width-1 :
			damage_concrete(column+1,row)
		#check left
		if column>0 :
			damage_concrete(column-1,row)
		#check up 
		if row<height-1 :
			damage_concrete(column,row+1)
		#check down
		if row>0 :
			damage_concrete(column,row-1)

func check_blocker(column,row):
		#check right
		if column<width-1 :
			if array[column+1][row]!=null:
				if array[column+1][row].color=="blocker":
					array[column+1][row].queue_free()
					array[column+1][row]=null
		#check left
		if column>0 :
			if array[column-1][row]!=null:
				if array[column-1][row].color=="blocker":
					array[column-1][row].queue_free()
					array[column-1][row]=null
		#check up 
		if row<height-1 :
			if array[column][row+1]!=null:
				if array[column][row+1].color=="blocker":
					array[column][row+1].queue_free()
					array[column][row+1]=null
		#check down
		if row>0 :
			if array[column][row-1]!=null:
				if array[column][row-1].color=="blocker":
					array[column][row-1].queue_free()
					array[column][row-1]=null

func check_slime(column,row):
	if slime_spaces !=null:
		#check left
		if column<width-1 :
			damage_slime(column+1,row)
		#check right
		if column>0 :
			damage_slime(column-1,row)
		#check up 
		if row<height-1 :
			damage_slime(column,row+1)
		#check down
		if row>0 :
			damage_slime(column,row-1)

signal collapse_done
func collapse_columns():
	SoundManager.play_fixed_sound("cascade_"+str(streak))
	SoundManager.play_fixed_sound("refill_"+str(streak))
	for i in width:
		for j in height:
			if array[i][j]==null and !restricted_fill(Vector2(i,j)): #and doesnt have restricted spaces above
				for k in range(j+1,height):
					if array[i][k]!=null:

						if !restricted_fill_checker(i,j,k):
							array[i][k].move(grid_to_pixel(i,j))
							array[i][j]=array[i][k]
							array[i][k]=null
							break
						else: #there is a restricted fill between j,k
							var t=restricted_fill_finder(i,j,k)
							if t==null:
								break
							else:
								print('T:',t)
								array[i][k].move(grid_to_pixel(i,t))
								array[i][t]=array[i][k]
								array[i][k]=null
								break
	destroy_sinkers()
	get_parent().get_node("refill_timer").start()
	emit_signal("collapse_done")

var rest_fill=false
func restricted_fill_checker(i,j,k):
	rest_fill=false
	for p in range(j,k+1):
		if restricted_fill(Vector2(i,p)):
			rest_fill=true
	if rest_fill:
		return true
	else:
		return false

func restricted_fill_finder(i,j,k):
	print('J:',j)
	print('K:',k)
	for p in range(j,k+1):
		if restricted_fill(Vector2(i,p)):
			print('P:',p)
			for t in range(p,height):
				if array[i][t]==null and !restricted_fill(Vector2(i,t)):
					return t

#refill_timer => refill_columns_2 => refill_columns => after_refill
func refill_columns_2(arg=true):
#	await get_tree().create_timer(.2).timeout
	for i in width:
		for j in height:
			if array[i][j]==null and !restricted_fill(Vector2(i,j)):
				
				if i-1>=0 and j+1<height and i+1<width and j+1<height:
					
					if array[i-1][j+1]!=null and !restricted_fill(Vector2(i-1,j+1)):
						array[i-1][j+1].move(grid_to_pixel(i,j))
						array[i][j]=array[i-1][j+1]
						array[i-1][j+1]=null
						print("2: ",i,j)
						refill_columns_2(false)
				
					elif array[i+1][j+1]!=null and !restricted_fill(Vector2(i+1,j+1)):
						array[i+1][j+1].move(grid_to_pixel(i,j))
						array[i][j]=array[i+1][j+1]
						array[i+1][j+1]=null
						print("1: ",i,j)
						refill_columns_2(false)
				#
				
				elif i-1>=0 and j+1<height:
					if array[i-1][j+1]!=null and !restricted_fill(Vector2(i-1,j+1)):
						array[i-1][j+1].move(grid_to_pixel(i,j))
						array[i][j]=array[i-1][j+1]
						array[i-1][j+1]=null
						print("2: ",i,j)
						refill_columns_2(false)
						
				
				elif i+1<width and j+1<height:
					if array[i+1][j+1]!=null and !restricted_fill(Vector2(i+1,j+1)):
						array[i+1][j+1].move(grid_to_pixel(i,j))
						array[i][j]=array[i+1][j+1]
						array[i+1][j+1]=null
						print("1: ",i,j)
						refill_columns_2(false)
						
	if arg==true:
		refill_columns()

signal refill_is_done
func refill_columns():
	print("refill_columns")
#	await "collapse_done"
	streak+=1
	for i in width:
		for j in height:
			if array[i][j]==null and !restricted_fill(Vector2(i,j)):
				if !above_restriction_checker(i,j):
					#
					var rand = randi_range(0,main_pieces.size())-1
					var piece = main_pieces[rand].instantiate()
					var loops=0
					while match_at(i,j,piece.color) and loops<100:
						rand=randi_range(0,main_pieces.size())-1
						loops+=1
						piece=main_pieces[rand].instantiate()
					#instance that piece from the array
					add_child(piece)
					#0,0 is top left j-x is above
					piece.position = grid_to_pixel(i,j+height_offset)
					piece.move(grid_to_pixel(i,j))
					array[i][j]=piece
					#
	#add a condition runs multiple times 
	emit_signal("refill_is_done")
	after_refill()

var slime_generated=false

func after_refill():
	bombs_were_found_after_swap=false
	find_and_spawn_bombs(false,true)
#	await refill_is_done
	print("after_refill")
	
	if !damaged_slime and !slime_generated:
		generate_slime()
		slime_generated=true
		$slime_timer.start()
	damaged_slime=false
	color_bomb_used=false
	if await is_deadlocked():
		$shuffle_timer.start()
		print("started_shuffle_timer")
		emit_signal("deadlocked")
	if state!=win:
		current_counter_value-=1
		emit_signal("update_counter",-1)
		if current_counter_value==0:
			state=wait
			get_parent().get_node("UI/moves_store").visible=true
			await is_booster_bought
			if booster_bought:
				print("movesbought")
				state=move
			else:
				print("movesnotbought")
				declare_game_over()
		else:
			state=move
	$hint_timer.start()
	if current_sinkers!=0:
		sinker_matcher()
	for i in width:
		for j in height:
			if array [i][j] !=null :
				if match_at(i,j,array[i][j].color) or array[i][j].matched :
					return
	streak=1

#used in refill columns checks if above j is not restricted 
#true means above is restricted
var restriction_flag
func above_restriction_checker(i,j):
	restriction_flag=false
	for h in range(j,height+1):
		if restricted_fill(Vector2(i,h)):
			restriction_flag=true
	if restriction_flag:
		return true
	else:
		return false

func sinker_matcher():
	for i in width:
		if array[i][0]!=null:
			if array[i][0].is_sinker==true:
				match_and_add_to_matches(i,0)
				get_parent().get_node("destroy_timer").start()
				print("sinker_matcher")

func find_normal_neighbour(column,row):
	#check right
	if is_in_grid(Vector2(column+1,row)) :
		if array[column+1][row] !=null and !is_piece_sinker(column+1,row) :
			return Vector2(column+1,row)
	#check left
	if is_in_grid(Vector2(column-1,row)) :
		if array[column-1][row] !=null and !is_piece_sinker(column-1,row) :
			return Vector2(column-1,row)
	#check up
	if is_in_grid(Vector2(column,row+1)) :
		if array[column][row+1] !=null and !is_piece_sinker(column,row+1) :
			return Vector2(column,row+1)
	#check down
	if is_in_grid(Vector2(column,row-1)) :
		if array[column][row-1] !=null and !is_piece_sinker(column,row-1) :
			return Vector2(column,row-1)
	else :
		return null

func generate_slime():
	if slime_spaces.size()>0 :
		var slime_made=false
		while !slime_made:
			#check random slime
			var random_num=randi_range(0,slime_spaces.size())
			var curr_x =slime_spaces[random_num].x
			var curr_y = slime_spaces[random_num].y
			var neighbour=find_normal_neighbour(curr_x,curr_y)
			if neighbour!=null :
				array[neighbour.x][neighbour.y].queue_free()
				array[neighbour.x][neighbour.y]=null
				slime_spaces.append(Vector2(neighbour.x,neighbour.y))
				spawn_slime(Vector2(neighbour.x,neighbour.y))
				slime_made=true

func _process(_delta):
	if state == move :
		touch_input()
		debug_input()
	if state==free_switch:
		touch_input(true)
	if state==booster:
		booster_input2()
	
var booster_type
func booster_input(boostertype):
	if boostertype=="color_bomb":
		state=wait
		var count=3
		var sound_count=1
		var happened=false
		#create random col row numbers 3 times
		#randi() %8 creates a random integer between 0-7
		while count>0:
			var randx = randi() %width
			var randy = randi() %height
			var temp = array[randx][randy]
			while temp == null or temp.is_special==true:
				randx = randi() % width
				randy = randi() % height
				temp = array[randx][randy]
			await get_tree().create_timer(.3).timeout
			make_bomb_spawn_effects("color",randx,randy)
			temp.make_color_bomb()
			SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
			count-=1
			sound_count+=1
			happened=true
		if happened==true:
			state=move

	if boostertype=="adjacent_bomb":
		state=wait
		var count=3
		var sound_count=1
		var happened=false
		while count>0:
			var randx = randi() %width
			var randy = randi() %height
			var temp = array[randx][randy]
			while temp == null or temp.is_special==true:
				randx = randi() % width
				randy = randi() % height
				temp = array[randx][randy]
			make_bomb_spawn_effects(temp.color,randx,randy)
			await get_tree().create_timer(.3).timeout
			temp.make_adjacent_bomb()
			SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
			temp.matched=true
			count-=1
			sound_count+=1
			state=move
			happened=true
		if happened==true:
			state=move

	if boostertype=="hammer":
		state=booster

	if boostertype=="free_switch":
		state=free_switch
	
	if boostertype=="colrow_bomb":
		state=wait
		var count=3
		var sound_count=1
		var happened=false
		while count>0:
			var randx = randi() %width
			var randy = randi() %height
			var temp = array[randx][randy]
			while temp == null or temp.is_special==true:
				randx = randi() % width
				randy = randi() % height
				temp = array[randx][randy]
			var rand = randi_range(0,100)
			if rand>=50:
				make_bomb_spawn_effects(temp.color,randx,randy)
				await get_tree().create_timer(.3).timeout
				temp.make_column_bomb()
				SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
			else:
				await get_tree().create_timer(.3).timeout
				make_bomb_spawn_effects(temp.color,randx,randy)
				temp.make_row_bomb()
				SoundManager.play_fixed_sound("booster_spawn_"+str(sound_count))
			temp.matched=true
			count-=1
			sound_count+=1
			state=move
			happened=true
		if happened==true:
			state=move

func _on_collapse_timer_timeout():
	collapse_columns()
	print('collapse_collumns')

func _on_refill_timer_timeout():
	refill_columns_2()
	print('refill_2')

func booster_input2():
	if Input.is_action_just_pressed("ui_touch"):
		var temp = get_global_mouse_position()
		var temp_grid=pixel_to_grid(temp.x, temp.y)
		if is_in_grid(pixel_to_grid(temp.x, temp.y)):
			damage_special(temp_grid.x,temp_grid.y)
			if array[temp_grid.x][temp_grid.y].is_special==true:
				array[temp_grid.x][temp_grid.y].matched=true
		state=move

func destroy_sinkers():
	for i in width-1 :
		if array[i][0]!=null:
			if array[i][0].color=="sinker" :
#				array[i][0]==null
#				array[i][0].queue_free()
				match_and_add_to_matches(i,0)
				current_sinkers-=1
				get_parent().get_node("destroy_timer").start()
				print("destroy_sinkers")
				SoundManager.play_fixed_sound("damage_slime")
				Input.vibrate_handheld(100)

func remove_concrete(place):
	for i in range(concrete_spaces.size()-1,-1,-1) :
		if concrete_spaces[i]==place :
			concrete_spaces.remove_at(i)
			effect_animator("concrete",place.x,place.y)

func remove_marmalade(place):
	for i in range(marmalade_spaces.size()-1,-1,-1) :
		if marmalade_spaces[i]==place :
			marmalade_spaces.remove_at(i)
			effect_animator("marmalade",place.x,place.y)

func remove_swirl(place):
	for i in range(swirl_spaces.size()-1,-1,-1) :
		if swirl_spaces[i]==place :
			swirl_spaces.remove_at(i)
			effect_animator("swirl",place.x,place.y)

func remove_slime(place):
	damaged_slime=true
	for i in range(slime_spaces.size()-1,-1,-1) :
		if slime_spaces[i]==place :
			slime_spaces.remove_at(i)
			effect_animator("slime",place.x,place.y)

func switch_pieces(place,direction,array_choice):
	if is_in_grid(place) and !restricted_fill(place) :
		if is_in_grid(place+direction) and !restricted_fill(place+direction):
			#first hold the place to swap with
			var holder=array_choice[place.x+direction.x][place.y+direction.y]
			#then set the swap spot as the original piece
			array_choice[place.x+direction.x][place.y+direction.y]=array_choice[place.x][place.y]
			#then set the original spot as the other piece
			array_choice[place.x][place.y]=holder
			
func switch_and_check(place,direction,array_choice):
	await switch_pieces(place,direction,array_choice)
	if await find_matches(true,array_choice):
		switch_pieces(place,direction,array_choice)
		return true
	switch_pieces(place,direction,array_choice)
	return false
	
func is_deadlocked():
	#create a copy of the og array
	clone_array=copy_array(array)
	for i in width:
		for j in height:
			if array[i][j]!=null and !restricted_fill(Vector2(i,j)):
				
				#switch and check right
				if !restricted_fill(Vector2(i+1,j)):
					if await switch_and_check(Vector2(i,j),Vector2(1,0),clone_array)==true:
						print("checkrightfound"+str(i,j))
						return false
						
				#switch and check up
				if !restricted_fill(Vector2(i,j+1)):
					if await switch_and_check(Vector2(i,j),Vector2(0,1),clone_array)==true:
						print("checkupfound"+str(i,j))
						return false
						
						
			if clone_array[i][j]!=null and !restricted_fill(Vector2(i,j)):
				#color
				if clone_array[i][j].is_color_bomb:
					return false
					
				#fishadjacent
				if clone_array[i][j].is_fish:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_adjacent_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_adjacent_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_adjacent_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_adjacent_bomb:
								return false
							
				#fishcol
				if clone_array[i][j].is_fish:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_column_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_column_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_column_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_column_bomb:
								return false
							
				#fishrow
				if clone_array[i][j].is_fish:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_row_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_row_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_row_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_row_bomb:
								return false
							
				#adjadj
				if clone_array[i][j].is_adjacent_bomb:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_adjacent_bomb:
								print("not_deadlocked_adj_adj1")
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_adjacent_bomb:
								print("not_deadlocked_adj_adj2")
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_adjacent_bomb:
								print("not_deadlocked_adj_adj3")
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_adjacent_bomb:
								print("not_deadlocked_adj_adj4")
								return false
						
				#coladjacent
				if clone_array[i][j].is_column_bomb:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_adjacent_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_adjacent_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_adjacent_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_adjacent_bomb:
								return false
						
				#rowadjacent
				if clone_array[i][j].is_row_bomb:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_adjacent_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_adjacent_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_adjacent_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_adjacent_bomb:
								return false
						
				#colrow
				if clone_array[i][j].is_column_bomb:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_row_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_row_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_row_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_row_bomb:
								return false
						
				#rowcol
				if clone_array[i][j].is_row_bomb:
					if i+1<width:
						if clone_array[i+1][j]!=null:
							if clone_array[i+1][j].is_column_bomb:
								return false
					if i-1>0 or i-1==0:
						if clone_array[i-1][j]!=null and i-1>0:
							if clone_array[i-1][j].is_column_bomb:
								return false
					if j+1<height:
						if clone_array[i][j+1]!=null:
							if clone_array[i][j+1].is_column_bomb:
								return false
					if j-1>0 or j-1==0:
						if clone_array[i][j-1]!=null:
							if clone_array[i][j-1].is_column_bomb:
								return false
								
	print("ISDEADLOCKED")
	return true


func copy_array(array_to_copy):
	var new_array=make_2d_array()
	for i in width:
		for j in height:
			new_array[i][j]=array_to_copy[i][j]
	return new_array


func clear_and_store_board():
	print("clear_and_store")
	var holder_array=[]
	for i in width:
		for j in height:
			if array[i][j]!=null and !restricted_fill(Vector2(i,j)) and !is_piece_sinker(i,j) and !is_piece_special(i,j):
				holder_array.append(array[i][j])
				array[i][j]=null
	return holder_array


func shuffle_board():
#	SoundManager.play_fixed_sound("shuffle")
	var holder_array=clear_and_store_board()
	print("shuffling")
	for i in width:
		for j in height:
			if !restricted_fill(Vector2(i,j)) and array[i][j]==null and !is_piece_sinker(i,j) and !is_piece_fish(i,j) and !is_piece_special(i,j):
				#choose random number and store it 
				var t=holder_array.size()
				var rand = randi_range(0,t-1)
				var piece = holder_array[rand]
				var loops=0
				while match_at(i,j,piece.color) and loops<100:
					rand=randi_range(0,holder_array.size()-1)
					loops+=1
					piece=holder_array[rand]
				piece.move(grid_to_pixel(i,j))
				array[i][j]=piece
				piece.position = grid_to_pixel(i,j)
				holder_array.remove_at(rand)
	if await is_deadlocked():
		await get_tree().create_timer(1.5).timeout
		shuffle_board()
		pass
		sinker_matcher()
	state=move
	
var hint_holder=[[],[],[],[]]
func generate_hint(query=false):
	hint_holder=[[],[],[],[]]
	if state==move:
		for i in width-1:
			for j in height-1:
				if array[i][j]!=null and !restricted_fill(Vector2(i,j)) and array[i][j].is_special==false and array[i][j].color!="blocker" and array[i][j].is_fish!=true and !restricted_move(Vector2(i,j)):
					
					if await switch_and_check(Vector2(i,j),Vector2(1,0),array):
						if source_color==array[i][j].color:
							hint_holder[0].append(array[i][j])
				
					if await switch_and_check(Vector2(i,j),Vector2(-1,0),array):
						if source_color==array[i][j].color:
							hint_holder[1].append(array[i][j])
				
					if await switch_and_check(Vector2(i,j),Vector2(0,1),array):
						if source_color==array[i][j].color:
							hint_holder[2].append(array[i][j])
				
					if await switch_and_check(Vector2(i,j),Vector2(0,-1),array):
						if source_color==array[i][j].color:
							hint_holder[3].append(array[i][j])
					
			#write a function that checks u-d-l-r  and appends special combos to hint holder
			
		for i in width:
			for j in height:
				if array[i][j]!=null:
					if array[i][j].is_special:
						#check up
						if j+1<width:
							if array[i][j+1]!=null:
								if array[i][j+1].is_special:
									hint_holder[0].append(array[i][j])
									hint_holder[0].append(array[i][j+1])
						#check down
						if j-1>=0:
							if array[i][j-1]!=null:
								if array[i][j-1].is_special:
									hint_holder[0].append(array[i][j])
									hint_holder[0].append(array[i][j-1])
						#check left
						if i-1>=0:
							if array[i-1][j]!=null:
								if array[i-1][j].is_special:
									hint_holder[0].append(array[i][j])
									hint_holder[0].append(array[i-1][j])
						#check right
						if i+1<width:
							if array[i+1][j]!=null:
								if array[i+1][j].is_special:
									hint_holder[0].append(array[i][j])
									hint_holder[0].append(array[i+1][j])
				
		if await is_deadlocked():
			shuffle_board()

		
		var rand=randi_range(0,hint_holder.size()-1)
		if hint_holder[0].size()==0 and hint_holder[1].size()==0 and hint_holder[2].size()==0 and hint_holder[3].size()==0:
			print("not_enough_to_create_hint_returned")
			return
			
		while hint_holder[rand].size()==0:
			print("line3045")
			rand=randi_range(0,hint_holder.size()-1)

		var rand2=randi_range(0,hint_holder[rand].size()-1)
		rand2=randi_range(0,hint_holder[rand].size()-1)
		
		var hint_piece=hint_holder[rand][rand2]
		if hint_piece.is_special==false:
			hint_piece.wiggle2()
		var hint_pos=pixel_to_grid(hint_piece.position.x,hint_piece.position.y)
		var pieces_that_match_with_hint=[]
		if !restricted_fill(Vector2(hint_pos.x,hint_pos.y)):
			if rand==0: #right
				#checks right
				if hint_pos.x+3<width:
					if array[hint_pos.x+2][hint_pos.y]!=null and array[hint_pos.x+3][hint_pos.y]!=null:
						if hint_piece.color==array[hint_pos.x+2][hint_pos.y].color and hint_piece.color==array[hint_pos.x+3][hint_pos.y].color:
							for k in range(2,8):
								if hint_pos.x+k<width and hint_pos.x+k>=0:
									if k==2:
										if hint_piece.color==array[hint_pos.x+k][hint_pos.y].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y])
									else:
										if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y)) and !restricted_fill(Vector2(hint_pos.x+k-1,hint_pos.y)):
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y].color and hint_piece.color==array[hint_pos.x+k-1][hint_pos.y].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y])
							if query:
								print("right-right")
				#checks up
				if hint_pos.x+1<width and hint_pos.y+2<height:
					if array[hint_pos.x+1][hint_pos.y+1]!=null and array[hint_pos.x+1][hint_pos.y+2]!=null:
						if hint_piece.color==array[hint_pos.x+1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y+2].color:
							for k in range(1,8):
								if hint_pos.y+k<height and hint_pos.y+k>=0:
									if k==1:
										if hint_piece.color==array[hint_pos.x+1][hint_pos.y+k].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y+k])
									else:
										if !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y+k)) and !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y+k-1)):
											if hint_piece.color==array[hint_pos.x+1][hint_pos.y+k].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y+k-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y+k])
							if query:
								print("right-up")
				#checks down
				if hint_pos.x+1<width and hint_pos.y-2>=0:
					if array[hint_pos.x+1][hint_pos.y-1]!=null and array[hint_pos.x+1][hint_pos.y-2]!=null:
						if hint_piece.color==array[hint_pos.x+1][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y-2].color:
							for k in range(1,8):
								if hint_pos.y-k<height and hint_pos.y-k>=0:
									if k==1:
										if hint_piece.color==array[hint_pos.x+1][hint_pos.y-k].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y-k])
									else:
										if !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y-k)) and !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y-k+1)):
											if hint_piece.color==array[hint_pos.x+1][hint_pos.y-k].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y-k+1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y-k])
							if query:
								print("right-down")
				#checks up and down
				if hint_pos.x+1<width and hint_pos.y+1<height and hint_pos.y-1>=0:
					if array[hint_pos.x+1][hint_pos.y+1]!=null and array[hint_pos.x+1][hint_pos.y-1]!=null:
						if hint_piece.color==array[hint_pos.x+1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y-1].color:
							for k in range(1,8):
								if hint_pos.y+k<height and hint_pos.y+k>=0:
									if hint_pos.y-k<height and hint_pos.y-k>=0:
										if k==1:
											if hint_piece.color==array[hint_pos.x+1][hint_pos.y+k].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y+k])
											if hint_piece.color==array[hint_pos.x+1][hint_pos.y-k].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y-k])
										else:
											if !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y+k)) and !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y+k-1)):
												if hint_piece.color==array[hint_pos.x+1][hint_pos.y+k].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y+k-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y+k])
											if !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y-k)) and !restricted_fill(Vector2(hint_pos.x+1,hint_pos.y-k+1)):
												if hint_piece.color==array[hint_pos.x+1][hint_pos.y-k].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y-k+1].color:
														pieces_that_match_with_hint.append(array[hint_pos.x+1][hint_pos.y-k])
							if query:
								print("right-updown")
			if rand==1: #left
				#checks left
				if hint_pos.x-3>=0:
					if array[hint_pos.x-2][hint_pos.y]!=null and array[hint_pos.x-3][hint_pos.y]!=null:
						if hint_piece.color==array[hint_pos.x-2][hint_pos.y].color and hint_piece.color==array[hint_pos.x-3][hint_pos.y].color:
							for k in range(2,8):
								if hint_pos.x-k<width and hint_pos.x-k>=0:
									if k==2:
										if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y)):
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y])
									else:
										if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y)):
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y].color and hint_piece.color==array[hint_pos.x-k+1][hint_pos.y].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y])
							if query:
								print("left-left")
				#checks up
				if hint_pos.x-1>=0 and hint_pos.y+2<height:
					if array[hint_pos.x-1][hint_pos.y+1]!=null and array[hint_pos.x-1][hint_pos.y+2]!=null :
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y+2].color:
							for k in range(1,8):
								if hint_pos.y+k<height and hint_pos.y+k>=0:
									if k==1:
										if hint_piece.color==array[hint_pos.x-1][hint_pos.y+k].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y+k])
									else:
										if !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y+k)) and !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y+k-1)):
											if hint_piece.color==array[hint_pos.x-1][hint_pos.y+k].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y+k-1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y+k])
							if query:
								print("left-up")
				#checks down
				if hint_pos.x-1>=0 and hint_pos.y-2>=0:
					if array[hint_pos.x-1][hint_pos.y-1]!=null and array[hint_pos.x-1][hint_pos.y-2]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y-2].color:
							for k in range(1,8):
								if hint_pos.y-k<height and hint_pos.y-k>=0:
									if k==1:
										if hint_piece.color==array[hint_pos.x-1][hint_pos.y-k].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y-k])
									else:
										if !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y-k)) and !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y-k+1)):
											if hint_piece.color==array[hint_pos.x-1][hint_pos.y-k].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y-k+1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y-k])
				#checks up and down
				if hint_pos.x-1>=0 and hint_pos.y-1>=0 and hint_pos.y+1<height:
					if array[hint_pos.x-1][hint_pos.y+1]!=null and array[hint_pos.x-1][hint_pos.y-1]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y-1].color:
							for k in range(1,8):
								if hint_pos.y+k<height and hint_pos.y+k>=0:
									if hint_pos.y+k<height and hint_pos.y-k>=0 and hint_pos.x-1>=0:
										if k==1:
											if hint_piece.color==array[hint_pos.x-1][hint_pos.y+k].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y+k])
											if hint_piece.color==array[hint_pos.x-1][hint_pos.y-k].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y-k])
										else:
											if !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y+k)) and !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y+k-1)):
												if hint_piece.color==array[hint_pos.x-1][hint_pos.y+k].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y+k-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y+k])
											if !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y-k)) and !restricted_fill(Vector2(hint_pos.x-1,hint_pos.y-k+1)):
												if hint_piece.color==array[hint_pos.x-1][hint_pos.y-k].color and hint_piece.color==array[hint_pos.x-1][hint_pos.y-k+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-1][hint_pos.y-k])
							if query:
								print("left-updown")
			if rand==2: #up
				#checks up
				if hint_pos.y+3<height:
					if array[hint_pos.x][hint_pos.y+2]!=null and array[hint_pos.x][hint_pos.y+3]!=null:
						if hint_piece.color==array[hint_pos.x][hint_pos.y+2].color and hint_piece.color==array[hint_pos.x][hint_pos.y+3].color:
							for k in range(2,8):
								if hint_pos.y+k<height and hint_pos.y+k>=0:
									if k==2:
										if !restricted_fill(Vector2(hint_pos.x,hint_pos.y+k)):
											if hint_piece.color==array[hint_pos.x][hint_pos.y+k].color:
													pieces_that_match_with_hint.append(array[hint_pos.x][hint_pos.y+k])
									else:
										if !restricted_fill(Vector2(hint_pos.x,hint_pos.y+k)):
											if hint_piece.color==array[hint_pos.x][hint_pos.y+k].color and hint_piece.color==array[hint_pos.x][hint_pos.y+k-1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x][hint_pos.y+k])
							if query:
								print("up-up")
				#checks left
				if hint_pos.x-2>=0:
					if array[hint_pos.x-1][hint_pos.y+1]!=null and array[hint_pos.x-2][hint_pos.y+1]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x-2][hint_pos.y+1].color:
							for k in range(1,8):
								if hint_pos.x-k<width and hint_pos.x-k>=0:
									if k==1:
										if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y+1)):
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y+1])
									else:
										if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y+1)) and !restricted_fill(Vector2(hint_pos.x-k+1,hint_pos.y+1)):
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x-k+1][hint_pos.y+1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y+1])
							if query:
								print("up-left")
				#checks right
				if hint_pos.x+2<width:
					if array[hint_pos.x+1][hint_pos.y+1]!=null and array[hint_pos.x+2][hint_pos.y+1]!=null:
						if hint_piece.color==array[hint_pos.x+1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+2][hint_pos.y+1].color:
							for k in range(1,8):
								if hint_pos.x+k<width and hint_pos.x+k>=0:
									if k==1:
										if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y+1)):
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y+1])
									else:
										if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y+1)):
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+k-1][hint_pos.y+1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y+1])
							if query:
								print("up-right")
				#checks left and right
				if hint_pos.x-1>=0 and hint_pos.x+1<width and hint_pos.y+1<width:
					if array[hint_pos.x-1][hint_pos.y+1]!=null and array[hint_pos.x+1][hint_pos.y+1]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y+1].color:
							for k in range(1,8):
								if hint_pos.x+k<width and hint_pos.x+k>=0:
									if hint_pos.x-k>=0:
										if k==1:
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y+1])
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y+1])
										else:
											if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y+1)) and !restricted_fill(Vector2(hint_pos.x-k+1,hint_pos.y+1)):
												if hint_piece.color==array[hint_pos.x-k][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x-k+1][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y+1])
											if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y+1)) and !restricted_fill(Vector2(hint_pos.x+k-1,hint_pos.y+1)):
												if hint_piece.color==array[hint_pos.x+k][hint_pos.y+1].color and hint_piece.color==array[hint_pos.x+k-1][hint_pos.y+1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y+1])
							if query:
								print("up-leftright")
			if rand==3: #down
				#checks down
				if hint_pos.y-3>=0:
					if array[hint_pos.x][hint_pos.y-2]!=null and array[hint_pos.x][hint_pos.y-3]!=null:
						if hint_piece.color==array[hint_pos.x][hint_pos.y-2].color and hint_piece.color==array[hint_pos.x][hint_pos.y-3].color:
							for k in range(2,8):
								if hint_pos.y-k<height and hint_pos.y-k>=0:
									if k==2:
										if hint_piece.color==array[hint_pos.x][hint_pos.y-k].color:
												pieces_that_match_with_hint.append(array[hint_pos.x][hint_pos.y-k])
									else:
										if !restricted_fill(Vector2(hint_pos.x,hint_pos.y-k)) and !restricted_fill(Vector2(hint_pos.x,hint_pos.y-k+1)):
											if hint_piece.color==array[hint_pos.x][hint_pos.y-k].color and hint_piece.color==array[hint_pos.x][hint_pos.y-k+1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x][hint_pos.y-k])
							if query:
								print("down-down")
				#checks left
				if hint_pos.x-2>=0:
					if array[hint_pos.x-1][hint_pos.y-1]!=null and array[hint_pos.x-2][hint_pos.y-1]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x-2][hint_pos.y-1].color:
							for k in range(1,8):
								if hint_pos.x-k<width and hint_pos.x-k>=0:
									if k==1:
										if hint_piece.color==array[hint_pos.x-k][hint_pos.y-1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y-1])
									else:
										if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y-1)) and !restricted_fill(Vector2(hint_pos.x-k+1,hint_pos.y-1)):
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x-k+1][hint_pos.y-1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y-1])
							if query:
								print("down-left")
				#checks right
				if hint_pos.x+2<width and hint_pos.y-1>=0:
					if array[hint_pos.x+1][hint_pos.y-1]!=null and array[hint_pos.x+2][hint_pos.y-1]!=null:
						if hint_piece.color==array[hint_pos.x+1][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x+2][hint_pos.y-1].color:
							for k in range(1,8):
								if hint_pos.x+k<width and hint_pos.x+k>=0:
									if k==1:
										if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y-1)):
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y-1])
									else:
										if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y-1)) and !restricted_fill(Vector2(hint_pos.x+k-1,hint_pos.y-1)):
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x+k-1][hint_pos.y-1].color:
												pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y-1])
							if query:
								print("down-right")
				#checks left and right
				if hint_pos.x-1>=0 and hint_pos.x+1<width:
					if array[hint_pos.x-1][hint_pos.y-1]!=null and array[hint_pos.x+1][hint_pos.y-1]!=null:
						if hint_piece.color==array[hint_pos.x-1][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x+1][hint_pos.y-1].color:
							for k in range(1,8):
								if hint_pos.x+k<width and hint_pos.x+k>=0:
									if hint_pos.x-k<width and hint_pos.x-k>=0:
										if k==1:
											if hint_piece.color==array[hint_pos.x-k][hint_pos.y-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y-1])
											if hint_piece.color==array[hint_pos.x+k][hint_pos.y-1].color:
													pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y-1])
										else:
											if !restricted_fill(Vector2(hint_pos.x-k,hint_pos.y-1)) and !restricted_fill(Vector2(hint_pos.x-k+1,hint_pos.y-1)):
												if hint_piece.color==array[hint_pos.x-k][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x-k+1][hint_pos.y-1].color:
														pieces_that_match_with_hint.append(array[hint_pos.x-k][hint_pos.y-1])
											if !restricted_fill(Vector2(hint_pos.x+k,hint_pos.y-1)) and !restricted_fill(Vector2(hint_pos.x+k-1,hint_pos.y-1)):
												if hint_piece.color==array[hint_pos.x+k][hint_pos.y-1].color and hint_piece.color==array[hint_pos.x+k-1][hint_pos.y-1].color:
														pieces_that_match_with_hint.append(array[hint_pos.x+k][hint_pos.y-1])
							if query:
								print("down-leftright")
			for k in pieces_that_match_with_hint.size():
				var hint_piece2=pieces_that_match_with_hint[k]
				hint_piece2.wiggle2()
			
		hint_holder[0].clear()
		hint_holder[1].clear()
		hint_holder[2].clear()
		hint_holder[3].clear()
		pieces_that_match_with_hint.clear()
		
signal swap_timer_done
#after refill pieces swap
func _on_swap_timer_timeout():
	swap_back()
	emit_signal("swap_timer_done")

func declare_game_over():
	emit_signal("game_over")
	state=wait
	print("game_over")

func _on_goal_holder_game_won():
	state=win
	print("game_won")

func _on_shuffle_timer_timeout():
	shuffle_board()
	pass

func _on_hint_timer_timeout():
	generate_hint()
	await get_tree().create_timer(3).timeout
	if state==move:
		$hint_timer.start()
	pass

func _on_destroy_timer_timeout():
	get_bomb_pieces()
	
#booster stuff 
#ui enables or disables use button
#when use pressed sends signal to grid then grid executes booster input

func _on_slime_timer_timeout():
	slime_generated=false

##turns 3 random pieces into color bombs
func _on_blue_booster_use_button_pressed():
	booster_input("color_bomb")

#turns 3 random pieces into adjacent bombs
func _on_green_booster_use_button_pressed():
	booster_input("adjacent_bomb")

#breaks specials pops bombs
func _on_yellow_booster_use_button_pressed():
	booster_input("hammer")

#switches 2 pieces for free
func _on_red_booster_use_button_pressed():
	booster_input("free_switch")

#turns 3 random pieces into colrow bombs
func _on_pink_booster_use_button_pressed():
	booster_input("colrow_bomb")
	
var tweenx=null #to make sure its not interrupted
var duration=.3
var distance=12
func shock_effect(i,j):
	if tweenx==null:
		tweenx=1
		var tween2=get_tree().create_tween()
		var tween3=get_tree().create_tween()
		var tween4=get_tree().create_tween()
		var tween6=get_tree().create_tween()
		var tween11=get_tree().create_tween()
		var tween16=get_tree().create_tween()
		var tween22=get_tree().create_tween()
		var tween23=get_tree().create_tween()
		var tween24=get_tree().create_tween()
		var tween10=get_tree().create_tween()
		var tween15=get_tree().create_tween()
		var tween20=get_tree().create_tween()
		tween2.set_trans(Tween.TRANS_SINE)
		tween3.set_trans(Tween.TRANS_SINE)
		tween4.set_trans(Tween.TRANS_SINE)
		tween6.set_trans(Tween.TRANS_SINE)
		tween11.set_trans(Tween.TRANS_SINE)
		tween16.set_trans(Tween.TRANS_SINE)
		tween22.set_trans(Tween.TRANS_SINE)
		tween23.set_trans(Tween.TRANS_SINE)
		tween24.set_trans(Tween.TRANS_SINE)
		tween10.set_trans(Tween.TRANS_SINE)
		tween15.set_trans(Tween.TRANS_SINE)
		tween20.set_trans(Tween.TRANS_SINE)
		
		#1-5
		#21-25
		var piece2
		var piece3
		var piece4
		var piece6
		var piece11
		var piece16
		var piece22
		var piece23
		var piece24
		var piece10
		var piece15
		var piece20
		if i-1>=0 and j+2<height:
			piece2=array[i-1][j+2]
		if j+2<height:
			piece3=array[i][j+2]
		if i+1<width and j+2<height:
			piece4=array[i+1][j+2]
		if i-2>=0 and j+1<height:
			piece6=array[i-2][j+1]
		if i-2>=0:
			piece11=array[i-2][j]
		if i-2>=0 and j-1>=0:
			piece16=array[i-2][j-1]
		if i-1>=0 and j-2>=0:
			piece22=array[i-1][j-2]
		if j-2>=0:
			piece23=array[i][j-2]
		if i+1<width and j-2>0:
			piece24=array[i+1][j-2]
		if i+2<width and j+1<height:
			piece10=array[i+2][j+1]
		if i+2<width:
			piece15=array[i+2][j]
		if i+2<width and j-1>=0:
			piece20=array[i+2][j-1]
		
		#UP
		if piece2!=null:
			tween2.tween_property(
				piece2,"position",Vector2(0,-distance),duration).as_relative()
			tween2.tween_property(
				piece2,"position",Vector2(0,distance),duration).as_relative()
		if piece3!=null:
			tween3.tween_property(
				piece3,"position",Vector2(0,-distance),duration).as_relative()
			tween3.tween_property(
				piece3,"position",Vector2(0,distance),duration).as_relative()
		if piece4!=null:
			tween4.tween_property(
				piece4,"position",Vector2(0,-distance),duration).as_relative()
			tween4.tween_property(
				piece4,"position",Vector2(0,distance),duration).as_relative()
			
		#DOWN
		if piece22!=null:
			tween22.tween_property(
				piece22,"position",Vector2(0,distance),duration).as_relative()
			tween22.tween_property(
				piece22,"position",Vector2(0,-distance),duration).as_relative()
		if piece23!=null:
			tween23.tween_property(
				piece23,"position",Vector2(0,distance),duration).as_relative()
			tween23.tween_property(
				piece23,"position",Vector2(0,-distance),duration).as_relative()
		if piece24!=null:
			tween24.tween_property(
				piece24,"position",Vector2(0,distance),duration).as_relative()
			tween24.tween_property(
				piece24,"position",Vector2(0,-distance),duration).as_relative()
			
		#LEFT
		if piece6!=null:
			tween6.tween_property(
				piece6,"position",Vector2(-distance,0),duration).as_relative()
			tween6.tween_property(
				piece6,"position",Vector2(distance,0),duration).as_relative()
		if piece11!=null:
			tween11.tween_property(
				piece11,"position",Vector2(-distance,0),duration).as_relative()
			tween11.tween_property(
				piece11,"position",Vector2(distance,0),duration).as_relative()
		if piece16!=null:
			tween16.tween_property(
				piece16,"position",Vector2(-distance,0),duration).as_relative()
			tween16.tween_property(
				piece16,"position",Vector2(distance,0),duration).as_relative()
			
		#RIGHT
		if piece10!=null:
			tween10.tween_property(
				piece10,"position",Vector2(distance,0),duration).as_relative()
			tween10.tween_property(
				piece10,"position",Vector2(-distance,0),duration).as_relative()
		if piece15!=null:
			tween15.tween_property(
				piece15,"position",Vector2(distance,0),duration).as_relative()
			tween15.tween_property(
				piece15,"position",Vector2(-distance,0),duration).as_relative()
		if piece20!=null:
			tween20.tween_property(
				piece20,"position",Vector2(distance,0),duration).as_relative()
			tween20.tween_property(
				piece20,"position",Vector2(-distance,0),duration).as_relative()
			
			
		tweenx=null
	else:
		await get_tree().create_timer(3).timeout
		tweenx=null
		
		
func _on_blue_pressed():
	debug_color="blue"
func _on_green_pressed():
	debug_color="green"
func _on_orange_pressed():
	debug_color="orange"
func _on_pink_pressed():
	debug_color="pink"
func _on_purple_pressed():
	debug_color="purple"
func _on_yellow_pressed():
	debug_color="yellow"

var booster_bought
signal is_booster_bought
func _on_ui_booster_bought(param):
	if param==true:
		booster_bought=true
	else:
		booster_bought=false
	emit_signal("is_booster_bought")


func _on_ice_one_pressed():
	ice_health=1

func _on_ice_two_pressed():
	ice_health=2

func _on_ice_three_pressed():
	ice_health=3


func _on_ice_four_pressed():
	ice_health=4

func _on_conc_1_pressed():
	concrete_health=1


func _on_conc_2_pressed():
	concrete_health=2


func _on_conc_3_pressed():
	concrete_health=3


func _on_conc_4_pressed():
	concrete_health=4


func _on_marm_1_pressed():
	marmalade_health=1


func _on_marm_2_pressed():
	marmalade_health=2


func _on_marm_3_pressed():
	marmalade_health=3


extends ScrollContainer

var pos = 0
#can scroll container be scenes ?

func scrollAllDown():
	#wait until all children have been added
	await get_tree().idle_frame
	for i in $VBoxContainer.get_children():
		$".".set_v_scroll(2533*18)

func _ready():
	scrollAllDown()


func _on_TextureButton_pressed():
	SoundManager.play_fixed_sound("button_pressed")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	pass
# warnings-disable

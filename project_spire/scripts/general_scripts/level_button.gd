extends TextureButton

func _ready():
	if level!=0:
		if GameDataManager.level_info.has(level):
			enabled = GameDataManager.level_info[level]["unlocked"]
		else:
			enabled = false

@export var level: int
@export var level_to_load: String


@export var enabled: bool


func _on_TextureButton_pressed():
	if enabled:
		SoundManager.play_fixed_sound("button_pressed")
		get_tree().change_scene_to_file(level_to_load)
# warnings-disable


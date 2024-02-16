extends TextureButton

@export var level:int
@export var enabled:bool

func _ready():
	if GameDataManager.level_info.has(level):
		if GameDataManager.level_info[level]["unlocked"]==true:
			enabled=true
		else:
			enabled=false

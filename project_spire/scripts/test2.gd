extends Node2D

var x=0
var y=0

func _ready():
	pass
	
	
func test():
	get_tree().create_timer(2).timeout
	print('test')

extends Node


var mapstart = preload("res://Test map.tscn")

func _ready():
	var mapstart_instance = mapstart.instance()
	add_child(mapstart_instance)

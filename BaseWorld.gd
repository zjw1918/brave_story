class_name BaseWorld
extends Node2D

@export var bgm: AudioStream

func _ready() -> void:
	if bgm:
		SoundManager.play_bgm(bgm)

func to_dict() -> Dictionary:
	var enemies_alive := []
	
	# enemy node should be grouped by "enemies"
	for node in get_tree().get_nodes_in_group("enemies"):
		var path := get_path_to(node) as String
		#adding: Boar
		#adding: Boar2
		enemies_alive.append(path)
	
	return {
		enemies_alive = enemies_alive,
	}
	
func from_dict(dict: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var path := get_path_to(node) as String
		if path not in dict.enemies_alive:
			node.queue_free()

#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_cancel"):
		#Game.back_to_title()

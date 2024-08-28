class_name BaseWorld
extends Node2D

func to_dict() -> Dictionary:
	var enemies_alive := []
	
	# enemy node should be grouped by "enemies"
	for node in get_tree().get_nodes_in_group("enemies"):
		var path := get_path_to(node)
		#adding: Boar
		#adding: Boar2
		enemies_alive.append(path)
	
	return {
		enemies_alive = enemies_alive,
	}
	
func from_dict(dict: Dictionary) -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var path := get_path_to(node)
		if path not in dict.enemies_alive:
			node.queue_free()

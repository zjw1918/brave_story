extends Node

@onready var stats: Stats = $Stats

func change_scene(path: String, entry_name: String) -> void:
	var tree := get_tree()
	tree.change_scene_to_file(path)
	await tree.tree_changed
	
	for node in tree.get_nodes_in_group("entry_points"):
		if node.name == entry_name:
			tree.current_scene.update_player(node.global_position, node.facing)
			break

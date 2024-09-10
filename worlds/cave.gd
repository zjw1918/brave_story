extends BaseWorld

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player

func _ready() -> void:
	var used := tile_map_layer.get_used_rect().grow(-1)
	var tile_size := tile_map_layer.tile_set.tile_size
	
	camera_2d.limit_top = used.position.y * tile_size.y
	camera_2d.limit_left = used.position.x * tile_size.x
	camera_2d.limit_bottom = used.end.y * tile_size.y
	camera_2d.limit_right = used.end.x * tile_size.x
	camera_2d.reset_smoothing()
	
	super()
	

func update_player(pos: Vector2, facing: Player.FACING) -> void:
	player.global_position = pos
	player.facing = facing
	player.fall_from_y = pos.y
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()


# the boss is died, need to change to game end scene
func _on_boar_died() -> void:
	await get_tree().create_timer(1).timeout
	Game.change_scene("res://ui/game_end_scene.tscn", {durarion=1})
	

extends BaseWorld

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player

func _ready() -> void:
	var used := tile_map.get_used_rect().grow(-1)
	var tile_size := tile_map.tile_set.tile_size
	
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

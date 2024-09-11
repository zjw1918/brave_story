extends Node

# audio player should not be interrupted by game pause,
# so the root node should set Process->Mode to Always

# bgm sound shoube be able to loop, set them loop in "Import" tab

enum BUS {MASTER, SFX, BGM}

const SFX_ATTACK := "Attack"
const SFX_JUMP := "Jump"
const SFX_UI_PRESSED := "UIPressed"
const SFX_UI_FOCUSED := "UIFocused"

var SFX_MAP := {}

@onready var sfx: Node = $SFX
@onready var bgm_player: AudioStreamPlayer = $BgmPlayer

func _ready() -> void:
	for node in sfx.get_children():
		SFX_MAP[node.name] = node

func play_sfx(name: String) -> void:
	var player := SFX_MAP.get(name) as AudioStreamPlayer
	if player:
		player.play()
		
func play_bgm(audio_stream: AudioStream) -> void:
	if bgm_player.stream == audio_stream and bgm_player.playing:
		return
	bgm_player.stream = audio_stream
	bgm_player.play()
	print("bgm name: ", audio_stream)

func resgister_ui_sounds(node: Node) -> void:
	var button := node as Button
	if button:
		button.pressed.connect(play_sfx.bind(SFX_UI_PRESSED))
		button.focus_entered.connect(play_sfx.bind(SFX_UI_FOCUSED))
	
	for child in node.get_children():
		resgister_ui_sounds(child)

func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

func set_volume(bus_index: int, v: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(v))

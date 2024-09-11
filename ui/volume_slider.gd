extends HSlider

@export var bus_name := "Master"

@onready var bus_index := AudioServer.get_bus_index(bus_name)

func _ready() -> void:
	value = SoundManager.get_volume(bus_index)
	
	#await timer.timeout
	value_changed.connect(func (v: float):
		print("master bus volume changed: ", v)
		SoundManager.set_volume(bus_index, v)
		Game.save_config()
	)
	
	SoundManager.play_bgm(preload("res://assets/bgm/27 14 BOSS fixing LOOP.mp3"))

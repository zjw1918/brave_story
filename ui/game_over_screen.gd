extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	hide()
	# when hide (default), do not care about _input logic 
	set_process_input(false)

func _input(event: InputEvent) -> void:
	# make other scene not respond to key input
	get_window().set_input_as_handled()
	
	# intrupt any interaction when playing anim
	if animation_player.is_playing():
		return
	
	# press any key to continue
	if (
		event is InputEventKey or 
		event is InputEventMouseButton or 
		event is InputEventJoypadButton
	):
		if event.is_pressed() and not event.is_echo():
			if Game.has_saved_file():
				Game.load_game()
			else:
				Game.back_to_title()

func show_game_over() -> void:
	show()
	set_process_input(true)
	animation_player.play("enter")
	SoundManager.play_bgm(preload("res://assets/bgm/29 15 game over LOOP.mp3"))
	

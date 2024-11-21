extends Control

@onready var resume: Button = $V/Actions/H/Resume

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SoundManager.register_ui_sounds(self)

	self.visibility_changed.connect(func ():
		get_tree().paused = self.visible
	)


func show_pause():
	show()
	resume.grab_focus()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		hide()
#		# set this action as handled, or it will pass to next scene
		get_window().set_input_as_handled()


func _on_resume_pressed() -> void:
	hide()


func _on_exit_pressed() -> void:
	Game.back_to_title()

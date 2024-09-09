extends Control

const LINES := [
	"大魔王终于被打败了",
	"森林又恢复了往日的宁静",
	"但这一切真的值得吗？",
]

@onready var label: Label = $Label

var current_index := -1
var tween: Tween

func _ready() -> void:
	show_line(0)

func _input(event: InputEvent) -> void:
	
	# intrupt any interaction when playing anim
	if tween.is_running():
		return
	
	# press any key to continue
	if (
		event is InputEventKey or 
		event is InputEventMouseButton or 
		event is InputEventJoypadButton
	):
		if event.is_pressed() and not event.is_echo():
			if current_index + 1 < LINES.size():
				show_line(current_index + 1)
			else:
				Game.back_to_title()

func show_line(index: int) -> void:
	current_index = index
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if index > 0:
		tween.tween_property(label, "modulate:a", 0, 1)
	else:
		label.modulate.a = 0
	
	# after tween anim, do set text content
	tween.tween_callback(label.set_text.bind(LINES[index]))
	tween.tween_property(label, "modulate:a", 1, 1)

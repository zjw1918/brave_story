extends TouchScreenButton

const DRAG_RADIUS := 16

var finger_index := -1
var drag_offset_pos: Vector2

@onready var original_pos := global_position

func _input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	if st:
		if st.is_pressed() and finger_index == -1:
			var global_pos := st.position * get_canvas_transform()
			var local_pos := to_local(global_pos)
			var rect := Rect2(Vector2.ZERO, texture_normal.get_size())
			if rect.has_point(local_pos):
				# pressed
				finger_index = st.index
				drag_offset_pos = global_pos - global_position
		elif not st.is_pressed() and st.index == finger_index:
			# release finger and the finger index is what we care
			finger_index = -1
			# reset know's position
			global_position = original_pos
			Input.action_release("move_right")
			Input.action_release("move_left")
			
	var sd := event as InputEventScreenDrag
	if sd and sd.index == finger_index:
		var wish_pos := sd.position * get_canvas_transform() - drag_offset_pos
		var movement := (wish_pos - original_pos).limit_length(DRAG_RADIUS)
		global_position = original_pos + movement
		
		# deal with the direction move
		var dir := movement / DRAG_RADIUS
		if dir.x > 0:
			Input.action_release("move_left")
			Input.action_press("move_right", dir.x)
		elif dir.x < 0:
			Input.action_release("move_right")
			Input.action_press("move_left", -dir.x)
			

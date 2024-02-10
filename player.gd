extends CharacterBody2D

const RUN_SPEED := 200.0
const JUNP_VELOCITY := -300

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * RUN_SPEED
	velocity.y += gravity * delta
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = JUNP_VELOCITY
	
	if is_on_floor():
		if is_zero_approx(direction):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")

	# horizontal flip player
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0
	
	move_and_slide()
	

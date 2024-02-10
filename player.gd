extends CharacterBody2D

const RUN_SPEED := 160.0
const ACCELERATION_FLOOR := RUN_SPEED / 0.2
# the acceleration in the air is faster than that in the floor
# so it only need 0.02s to finish the acc
const ACCELERATION_AIR := RUN_SPEED / 0.02
const JUNP_VELOCITY := -320

var gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump") and velocity.y < JUNP_VELOCITY / 2:
		velocity.y = JUNP_VELOCITY / 2

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := ACCELERATION_FLOOR if is_on_floor() else ACCELERATION_AIR
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
	
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		velocity.y = JUNP_VELOCITY
		coyote_timer.stop()
		jump_request_timer.stop()
	
	if is_on_floor():
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")

	# horizontal flip player
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0
	
	var was_on_floor := is_on_floor()
	
	move_and_slide()
	
	# handle coyote time jump
	if is_on_floor() != was_on_floor:
		# 原先在地面上的，并且不是因为起跳离开的地面
		if was_on_floor and not should_jump:
			coyote_timer.start()
		else:
			coyote_timer.stop()
	

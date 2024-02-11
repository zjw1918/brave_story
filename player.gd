extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
}

const GROUND_STATE := [State.IDLE, State.RUNNING, State.LANDING]
const RUN_SPEED := 160.0
const ACCELERATION_FLOOR := RUN_SPEED / 0.2
# the acceleration in the air is faster than that in the floor
# so it only need 0.02s to finish the acc
const ACCELERATION_AIR := RUN_SPEED / 0.02
const JUNP_VELOCITY := -320

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUNP_VELOCITY / 2:
			velocity.y = JUNP_VELOCITY / 2

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(default_gravity, delta)
		State.RUNNING:
			move(default_gravity, delta)
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)
		State.FALL:
			move(default_gravity, delta)
		State.LANDING:
			stand(delta)
	is_first_tick = false
	
func move(gravity: float, delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := ACCELERATION_FLOOR if is_on_floor() else ACCELERATION_AIR
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
	
	# horizontal flip player
	if not is_zero_approx(direction):
		sprite_2d.flip_h = direction < 0

	move_and_slide()
	
func stand(delta: float) -> void:
	var acceleration := ACCELERATION_FLOOR if is_on_floor() else ACCELERATION_AIR
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += default_gravity * delta
	move_and_slide()
	

func get_next_state(state: State) -> State:
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	
	var direction := Input.get_axis("move_left", "move_right")
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if not is_on_floor():
				return State.FALL
			if not is_still:
				return State.RUNNING

		State.RUNNING:
			if not is_on_floor():
				return State.FALL
			if is_still:
				return State.IDLE
				
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
		State.FALL:
			if is_on_floor():
				return State.LANDING if is_still else State.RUNNING
		State.LANDING:
			if not animation_player.is_playing():
				return State.IDLE
	return state

func transition_state(from: State, to: State) -> void:
	if from not in GROUND_STATE and to in GROUND_STATE:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUNP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATE:
				coyote_timer.start()
		State.LANDING:
			animation_player.play("landing")
	is_first_tick = true
			


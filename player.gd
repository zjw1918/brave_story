extends CharacterBody2D

enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
	LANDING,
	WALL_SLIDING,
	WALL_JUMP,
}

const GROUND_STATE := [State.IDLE, State.RUNNING, State.LANDING]
const RUN_SPEED := 160.0
const ACCELERATION_FLOOR := RUN_SPEED / 0.2
# the acceleration in the air is faster than that in the floor
# so it only need 0.02s to finish the acc
const ACCELERATION_AIR := RUN_SPEED / 0.1
const JUMP_VELOCITY := -320
const WALL_JUMP_VELOCITY := Vector2(380, -280)

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var hand_checker: RayCast2D = $Graphics/HandChecker
@onready var foot_checker: RayCast2D = $Graphics/FootChecker
@onready var state_machine: StateMachine = $StateMachine


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2

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
			stand(default_gravity, delta)
		State.WALL_SLIDING:
			move(default_gravity / 3.0, delta)
			# get the wall facing, -1 or 1
			graphics.scale.x = get_wall_normal().x
		State.WALL_JUMP:
			if state_machine.state_time < 0.1:
				stand(0.0 if is_first_tick else default_gravity, delta)
				graphics.scale.x = get_wall_normal().x
			else:
				move(default_gravity, delta)
	is_first_tick = false
	
func move(gravity: float, delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var acceleration := ACCELERATION_FLOOR if is_on_floor() else ACCELERATION_AIR
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
	
	# horizontal flip player
	if not is_zero_approx(direction):
		graphics.scale.x = -1 if direction < 0 else 1

	move_and_slide()
	
func stand(gravity: float, delta: float) -> void:
	var acceleration := ACCELERATION_FLOOR if is_on_floor() else ACCELERATION_AIR
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += gravity * delta
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
			if can_wall_slide():
				return State.WALL_SLIDING
				
		State.LANDING:
			if not is_still:
				return State.RUNNING
			if not animation_player.is_playing():
				return State.IDLE
		
		State.WALL_SLIDING:
			# it's better to enter State.WALL_JUMP in the non first frame
			if jump_request_timer.time_left > 0 and state_machine.state_time > 0.08:
				return State.WALL_JUMP
			if is_on_floor():
				return State.IDLE
			if not is_on_wall():
				return State.FALL
				
		State.WALL_JUMP:
			# can't enter WALL_SLIDING state immediately
			# need to be not the first tick
			if can_wall_slide() and not is_first_tick:
				return State.WALL_SLIDING
			if velocity.y >= 0:
				return State.FALL
	return state

func can_wall_slide() -> bool:
	return is_on_wall() and hand_checker.is_colliding() and foot_checker.is_colliding()

func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	if from not in GROUND_STATE and to in GROUND_STATE:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUNNING:
			animation_player.play("running")
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATE:
				coyote_timer.start()
		State.LANDING:
			animation_player.play("landing")
		State.WALL_SLIDING:
			animation_player.play("wall_sliding")
		State.WALL_JUMP:
			animation_player.play("jump")
			velocity = WALL_JUMP_VELOCITY
			velocity.x *= get_wall_normal().x
			jump_request_timer.stop()

	# for debug: slow time			
	#if to == State.WALL_JUMP:
		#Engine.time_scale = 0.3
	#if from == State.WALL_JUMP:
		#Engine.time_scale = 1.0
	is_first_tick = true
			


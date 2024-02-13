extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
}

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calmdown_timer: Timer = $CalmdownTimer

func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	return player_checker.get_collider() is Player

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		State.WALK:
			move(max_speed / 3, delta)
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction *= -1
			move(max_speed, delta)
			if can_see_player():
				calmdown_timer.start()

func get_next_state(state: State) -> State:
	if can_see_player():
		return State.RUN
	
	match state:
		State.IDLE:
			if state_machine.state_time > 2:
				return State.WALK
		State.WALK:
			# is_colliding has cache, sometimes should call force_raycast_update to make it effect
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE
		State.RUN:
			if calmdown_timer.is_stopped():
				return State.WALK
	
	return state

func transition_state(from: State, to: State) -> void:
	match to:
		State.IDLE:
			animation_player.play("idle")
			if wall_checker.is_colliding():
				direction *= -1
		State.WALK:
			animation_player.play("walk")
			if not floor_checker.is_colliding():
				direction *= -1
				floor_checker.force_raycast_update()
		State.RUN:
			animation_player.play("run")

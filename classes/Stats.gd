class_name Stats
extends Node

signal health_change
signal energy_change

@export var max_health: int = 3
@export var max_energy: float = 10
@export var energy_regen: float = 0.8

@onready var health: int = max_health:
	set(v):
		v = clampi(v, 0, max_health)
		if health == v:
			return
		health = v
		health_change.emit()

@onready var energy: float = max_energy:
	set(v):
		v = clampf(v, 0, max_energy)
		if energy == v:
			return
		energy = v
		energy_change.emit()

func _process(delta: float) -> void:
	energy += energy_regen * delta

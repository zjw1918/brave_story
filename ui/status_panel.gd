extends HBoxContainer

@export var stats: Stats

@onready var health_bar: TextureProgressBar = $VBoxContainer/HealthBar
@onready var eased_health_bar: TextureProgressBar = $VBoxContainer/HealthBar/EasedHealthBar
@onready var energy_bar: TextureProgressBar = $VBoxContainer/EnergyBar

func _ready():
	if not stats:
		stats = Game.player_stats
	
	stats.health_change.connect(update_health)
	update_health(true)
	stats.energy_change.connect(update_energy)
	update_energy()
	
func update_health(skip_anim: bool = false) -> void:
	var percentage = stats.health / float(stats.max_health)
	health_bar.value = percentage
	if skip_anim:
		eased_health_bar.value = percentage
	else:
		create_tween().tween_property(eased_health_bar, "value", percentage, 0.3)

func update_energy() -> void:
	var percentage = stats.energy / stats.max_energy
	energy_bar.value = percentage

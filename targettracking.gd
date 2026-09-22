extends Area2D

# Vitesse maximale en pixels par seconde
@export var max_speed: float = 380.0
# Facteur d'inertie / lissage (plus c'est bas, plus la cible a de l'élan et glisse)
@export var acceleration: float = 4.5

var current_velocity: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO

var is_hovered: bool = false
var tracked_time_msec: int = 0
var last_enter_time: int = 0

var distance_samples: Array[float] = []

var strafe_timer: float = 0.0
var next_strafe_interval: float = 0.8

func _ready() -> void:
	pick_new_target_velocity()

func _process(delta: float) -> void:
	# 1. Gestion du changement de rythme / strafe
	strafe_timer += delta
	if strafe_timer >= next_strafe_interval:
		pick_new_target_velocity()

	# 2. Lissage du mouvement (interpolation inertielle type Aim Lab)
	current_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
	position += current_velocity * delta

	# 3. Gestion douce des rebords de l'écran
	var screen_size = get_viewport_rect().size
	var radius = 32.0

	if position.x <= radius:
		position.x = radius
		target_velocity.x = abs(target_velocity.x)
		current_velocity.x = abs(current_velocity.x) * 0.5
	elif position.x >= screen_size.x - radius:
		position.x = screen_size.x - radius
		target_velocity.x = -abs(target_velocity.x)
		current_velocity.x = -abs(current_velocity.x) * 0.5

	if position.y <= radius:
		position.y = radius
		target_velocity.y = abs(target_velocity.y)
		current_velocity.y = abs(current_velocity.y) * 0.5
	elif position.y >= screen_size.y - radius:
		position.y = screen_size.y - radius
		target_velocity.y = -abs(target_velocity.y)
		current_velocity.y = -abs(current_velocity.y) * 0.5

	# 4. Échantillonnage de la précision
	var mouse_pos = get_global_mouse_position()
	distance_samples.append(position.distance_to(mouse_pos))

	# 5. Mesure du temps passé sur la cible
	if is_hovered:
		var now = Time.get_ticks_msec()
		tracked_time_msec += (now - last_enter_time)
		last_enter_time = now

func pick_new_target_velocity() -> void:
	strafe_timer = 0.0
	# Intervalles variables pour alterner entre longs virages fluides et micro-strafes
	next_strafe_interval = randf_range(0.4, 1.4)

	var random_angle = randf_range(0.0, TAU)
	# Variation de vitesse entre 50 % et 100 % pour simuler des phases de ralentissement
	var speed_factor = randf_range(0.5, 1.0)
	target_velocity = Vector2(cos(random_angle), sin(random_angle)) * (max_speed * speed_factor)

func _on_mouse_entered() -> void:
	is_hovered = true
	last_enter_time = Time.get_ticks_msec()

func _on_mouse_exited() -> void:
	if is_hovered:
		var now = Time.get_ticks_msec()
		tracked_time_msec += (now - last_enter_time)
		is_hovered = false

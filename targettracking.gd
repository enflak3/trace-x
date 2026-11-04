extends Area2D

@export var max_speed: float = 380.0
@export var acceleration: float = 4.5
@export var target_scale: float = 1.0
@export var strafe_interval_min: float = 0.5
@export var strafe_interval_max: float = 1.3
# Marge d'éloignement par rapport aux bords de l'écran (en pixels)
@export var screen_margin: float = 120.0

var current_velocity: Vector2 = Vector2.ZERO
var target_velocity: Vector2 = Vector2.ZERO

var is_hovered: bool = false
var is_moving: bool = false
var tracked_time_msec: int = 0
var last_enter_time: int = 0

var distance_samples: Array[float] = []

var strafe_timer: float = 0.0
var next_strafe_interval: float = 0.8

func apply_difficulty(preset: Dictionary) -> void:
	max_speed = preset.get("max_speed", 380.0)
	acceleration = preset.get("acceleration", 4.5)
	target_scale = preset.get("target_scale", 1.0)
	strafe_interval_min = preset.get("strafe_min", 0.5)
	strafe_interval_max = preset.get("strafe_max", 1.3)
	scale = Vector2(target_scale, target_scale)

func start_moving() -> void:
	tracked_time_msec = 0
	distance_samples.clear()
	is_moving = true
	# Si le joueur a déjà placé son curseur sur la boule pendant les 3 s, on démarre le chrono ici
	if is_hovered:
		last_enter_time = Time.get_ticks_msec()
	pick_new_target_velocity()

func _process(delta: float) -> void:
	if not is_moving:
		return

	var screen_size = get_viewport_rect().size
	var bounds_min = Vector2(screen_margin, screen_margin)
	var bounds_max = screen_size - Vector2(screen_margin, screen_margin)
	
	# Vérifie si la cible s'approche de la zone interdite
	var near_boundary = (position.x <= bounds_min.x or position.x >= bounds_max.x or 
						 position.y <= bounds_min.y or position.y >= bounds_max.y)

	strafe_timer += delta
	# Si le timer expire OU si la cible arrive trop près d'un bord, on change de direction
	if strafe_timer >= next_strafe_interval or near_boundary:
		pick_new_target_velocity()

	# Lissage de trajectoire avec inertie (Aim Lab style)
	current_velocity = current_velocity.lerp(target_velocity, acceleration * delta)
	position += current_velocity * delta

	# Clamp de sécurité absolu pour ne jamais sortir de la zone utile
	position.x = clamp(position.x, bounds_min.x, bounds_max.x)
	position.y = clamp(position.y, bounds_min.y, bounds_max.y)

	# Échantillonnage de la précision
	var mouse_pos = get_global_mouse_position()
	distance_samples.append(position.distance_to(mouse_pos))

	# Cumul du temps de tracking
	if is_hovered:
		var now = Time.get_ticks_msec()
		tracked_time_msec += (now - last_enter_time)
		last_enter_time = now

func pick_new_target_velocity() -> void:
	strafe_timer = 0.0
	next_strafe_interval = randf_range(strafe_interval_min, strafe_interval_max)

	var screen_center = get_viewport_rect().size / 2.0
	var to_center = (screen_center - position).normalized()
	
	# Calcule la distance relative par rapport au centre (0.0 au centre, 1.0 aux bords)
	var max_offset = max((screen_center - Vector2(screen_margin, screen_margin)).length(), 1.0)
	var current_offset = position.distance_to(screen_center)
	var danger_factor = clamp(current_offset / max_offset, 0.0, 1.0)
	
	# Direction aléatoire libre
	var random_angle = randf_range(0.0, TAU)
	var random_dir = Vector2(cos(random_angle), sin(random_angle))
	
	# Plus la cible s'éloigne du centre, plus la force de rappel vers le milieu prend le dessus
	var blended_dir = random_dir.lerp(to_center, danger_factor * 0.85).normalized()
	
	var speed_factor = randf_range(0.6, 1.0)
	target_velocity = blended_dir * (max_speed * speed_factor)

func _on_mouse_entered() -> void:
	is_hovered = true
	if is_moving:
		last_enter_time = Time.get_ticks_msec()

func _on_mouse_exited() -> void:
	if is_hovered:
		if is_moving:
			var now = Time.get_ticks_msec()
			tracked_time_msec += (now - last_enter_time)
		is_hovered = false

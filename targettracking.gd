extends Area2D

# Vitesse de déplacement en pixels par seconde
@export var speed: float = 300.0

var velocity: Vector2 = Vector2.ZERO
var is_hovered: bool = false
var tracked_time_msec: int = 0
var last_enter_time: int = 0

func _ready() -> void:
	# Direction initiale aléatoire (angle normalisé)
	var random_angle = randf_range(0.0, TAU)
	velocity = Vector2(cos(random_angle), sin(random_angle)) * speed

func _process(delta: float) -> void:
	# Déplacement continu
	position += velocity * delta
	
	# Gestion des rebonds sur les bordures de l'écran
	var screen_size = get_viewport_rect().size
	var radius = 32.0 # Marge adaptée au rayon de ta cible
	
	if position.x <= radius:
		position.x = radius
		velocity.x = -velocity.x
	elif position.x >= screen_size.x - radius:
		position.x = screen_size.x - radius
		velocity.x = -velocity.x
		
	if position.y <= radius:
		position.y = radius
		velocity.y = -velocity.y
	elif position.y >= screen_size.y - radius:
		position.y = screen_size.y - radius
		velocity.y = -velocity.y
		
	# Si la souris survole la cible, on cumule le temps
	if is_hovered:
		var now = Time.get_ticks_msec()
		tracked_time_msec += (now - last_enter_time)
		last_enter_time = now

func _on_mouse_entered() -> void:
	is_hovered = true
	last_enter_time = Time.get_ticks_msec()

func _on_mouse_exited() -> void:
	if is_hovered:
		var now = Time.get_ticks_msec()
		tracked_time_msec += (now - last_enter_time)
		is_hovered = false

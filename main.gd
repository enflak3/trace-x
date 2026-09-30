extends Node2D

var target_scene: PackedScene = preload("res://Target.tscn")

const MAX_TARGETS: int = 10
var targets_hit_count: int = 0
var total_clicks: int = 0

var current_target: Area2D = null
var target_spawn_pos: Vector2 = Vector2.ZERO
var mouse_pos_at_spawn: Vector2 = Vector2.ZERO

var mouse_path: Array[Vector2] = []
var is_tracking_path: bool = false
var is_session_active: bool = false

# Timestamps pour immuniser contre les doubles clics rapides / rebonds touchpad
var last_hit_timestamp_ms: int = 0

var session_data: Array = []

func _ready() -> void:
	is_session_active = true
	spawn_target()

func _process(_delta: float) -> void:
	if is_tracking_path:
		var current_mouse = get_global_mouse_position()
		if mouse_path.is_empty() or mouse_path[-1].distance_to(current_mouse) > 2.0:
			mouse_path.append(current_mouse)

func _unhandled_input(event: InputEvent) -> void:
	if not is_session_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var now = Time.get_ticks_msec()
		# Si un hit a eu lieu il y a moins de 60 ms (rebond de trame / touchpad), on ignore
		if now - last_hit_timestamp_ms < 60:
			return

		# Sécurité supplémentaire : vérifie si le clic est tombé dans le rayon de la cible active
		if is_instance_valid(current_target):
			var dist = get_global_mouse_position().distance_to(current_target.position)
			if dist <= 36.0: # Rayon de la cible avec marge
				return

		total_clicks += 1
		print("Tir manqué ! Total clics : ", total_clicks)

func spawn_target() -> void:
	if targets_hit_count >= MAX_TARGETS:
		finish_session()
		return

	var target = target_scene.instantiate()
	var screen_size = get_viewport_rect().size
	var margin = 64.0

	target.position = Vector2(
		randf_range(margin, screen_size.x - margin),
		randf_range(margin, screen_size.y - margin)
	)

	current_target = target
	target_spawn_pos = target.position
	mouse_pos_at_spawn = get_global_mouse_position()

	mouse_path.clear()
	mouse_path.append(mouse_pos_at_spawn)
	is_tracking_path = true

	target.target_hit.connect(_on_target_hit)
	add_child(target)

func _on_target_hit(reaction_time: int, target_pos: Vector2, click_pos: Vector2) -> void:
	if not is_session_active:
		return

	last_hit_timestamp_ms = Time.get_ticks_msec()
	is_tracking_path = false
	total_clicks += 1
	targets_hit_count += 1



	var direct_distance = mouse_pos_at_spawn.distance_to(click_pos)
	var actual_path_distance = 0.0
	for i in range(1, mouse_path.size()):
		actual_path_distance += mouse_path[i - 1].distance_to(mouse_path[i])

	var path_efficiency = (direct_distance / actual_path_distance) if actual_path_distance > 0 else 1.0
	var micro_corrections = calculate_micro_corrections(mouse_path)

	var approach_vector = click_pos - mouse_pos_at_spawn
	var flick_angle_deg = rad_to_deg(approach_vector.angle())

	var target_vector = target_pos - mouse_pos_at_spawn
	var overshoot_metric = 0.0
	var hit_type = "exact"

	if target_vector.length() > 0:
		var normalized_axis = target_vector.normalized()
		var projected_dist = (click_pos - mouse_pos_at_spawn).dot(normalized_axis)
		var ideal_dist = target_vector.length()
		overshoot_metric = projected_dist - ideal_dist

		if overshoot_metric > 4.0:
			hit_type = "overshoot"
		elif overshoot_metric < -4.0:
			hit_type = "undershoot"

	var flick_speed = direct_distance / float(reaction_time) if reaction_time > 0 else 0.0

	var shot_record = {
		"target_id": targets_hit_count,
		"reaction_time_ms": reaction_time,
		"flick_distance_px": snapped(direct_distance, 0.1),
		"path_distance_px": snapped(actual_path_distance, 0.1),
		"path_efficiency": snapped(path_efficiency, 0.001),
		"micro_corrections": micro_corrections,
		"flick_angle_deg": snapped(flick_angle_deg, 0.1),
		"flick_speed_px_per_ms": snapped(flick_speed, 0.01),
		"hit_classification": hit_type,
		"overshoot_offset_px": snapped(overshoot_metric, 0.1),
		"offset_from_center_px": snapped(target_pos.distance_to(click_pos), 0.1)
	}
	session_data.append(shot_record)

	print("Tir #", targets_hit_count, " | ", reaction_time, "ms | Efficacité : ", snapped(path_efficiency, 0.01))

	current_target = null

	if targets_hit_count >= MAX_TARGETS:
		finish_session()
	else:
		spawn_target()

func finish_session() -> void:
	if not is_session_active:
		return
	is_session_active = false

	# 1. Précision brute (Hit Rate)
	var hit_rate = (float(targets_hit_count) / float(total_clicks)) * 100.0 if total_clicks > 0 else 0.0

	# 2. Précision de centrage (moyenne sur tous les tirs réussis)
	# Rayon standard de la cible : 32 px (ajuste si ton CollisionShape2D est différent)
	var target_radius: float = 32.0
	var total_centering_pct: float = 0.0

	for shot in session_data:
		var dist: float = shot.get("offset_from_center_px", 0.0)
		# 100% au centre pile, 0% si touché à l'extrême bord du rayon
		var shot_centering = clamp((1.0 - (dist / target_radius)) * 100.0, 0.0, 100.0)
		total_centering_pct += shot_centering

	var avg_centering = (total_centering_pct / float(session_data.size())) if not session_data.is_empty() else 0.0

	print("--- SESSION FLICK TERMINÉE ---")
	print("Hit Rate : ", snapped(hit_rate, 0.01), "%")
	print("Centrage moyen : ", snapped(avg_centering, 0.01), "%")

	var flick_metrics = {
		"total_targets": MAX_TARGETS,
		"total_clicks": total_clicks,
		"hit_rate_pct": snapped(hit_rate, 0.01),
		"centering_pct": snapped(avg_centering, 0.01),
		"shots": session_data
	}

	Sessionmanager.save_session("flick", flick_metrics)
	get_tree().change_scene_to_file("res://ResultScreen.tscn")

func calculate_micro_corrections(points: Array[Vector2]) -> int:
	if points.size() < 3:
		return 0
		
	var corrections: int = 0
	var threshold_angle: float = deg_to_rad(35.0)
	
	for i in range(1, points.size() - 1):
		var v1 = (points[i] - points[i - 1]).normalized()
		var v2 = (points[i + 1] - points[i]).normalized()
		
		if v1.length_squared() > 0 and v2.length_squared() > 0:
			var angle_diff = abs(v1.angle_to(v2))
			if angle_diff > threshold_angle:
				corrections += 1
				
	return corrections

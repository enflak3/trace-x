extends Node2D

var tracking_target_scene: PackedScene = preload("res://TargetTracking.tscn")

const SESSION_DURATION_SEC: float = 15.0
var time_elapsed: float = 0.0
var active_target: Area2D = null
var session_active: bool = false

func _ready() -> void:
	start_tracking_session()

func _process(delta: float) -> void:
	if not session_active:
		return
		
	time_elapsed += delta
	if time_elapsed >= SESSION_DURATION_SEC:
		finish_tracking_session()

func start_tracking_session() -> void:
	time_elapsed = 0.0
	session_active = true
	
	active_target = tracking_target_scene.instantiate()
	active_target.position = get_viewport_rect().size / 2.0
	add_child(active_target)
	print("--- SESSION TRACKING DÉMARRÉE (15 s) ---")

func finish_tracking_session() -> void:
	session_active = false
	var total_time_ms = int(SESSION_DURATION_SEC * 1000.0)
	var tracked_ms = active_target.tracked_time_msec
	var tracking_ratio = (float(tracked_ms) / float(total_time_ms)) * 100.0
	
	var samples = active_target.distance_samples
	var avg_distance: float = 0.0
	if not samples.is_empty():
		var total_dist: float = 0.0
		for dist in samples:
			total_dist += dist
		avg_distance = total_dist / float(samples.size())
	
	var tracking_metrics = {
		"duration_sec": SESSION_DURATION_SEC,
		"tracked_time_ms": tracked_ms,
		"total_time_ms": total_time_ms,
		"time_on_target_pct": snapped(tracking_ratio, 0.01),
		"avg_offset_px": snapped(avg_distance, 0.1)
	}
	
	# Appel du Singleton
	Sessionmanager.save_session("tracking", tracking_metrics)
	active_target.queue_free()
	# Transition automatique vers le récap
	get_tree().change_scene_to_file("res://ResultScreen.tscn")

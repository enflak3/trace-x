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
	
	print("--- SESSION TRACKING TERMINÉE ---")
	print("Temps suivi : ", tracked_ms, " ms / ", total_time_ms, " ms")
	print("Précision de tracking : ", snapped(tracking_ratio, 0.01), " %")
	
	export_tracking_data(tracked_ms, total_time_ms, tracking_ratio)
	active_target.queue_free()

func export_tracking_data(tracked_ms: int, total_ms: int, ratio: float) -> void:
	var payload = {
		"mode": "tracking",
		"timestamp": Time.get_unix_time_from_system(),
		"duration_sec": SESSION_DURATION_SEC,
		"tracked_time_ms": tracked_ms,
		"total_time_ms": total_ms,
		"accuracy_pct": snapped(ratio, 0.01)
	}
	
	var file = FileAccess.open("res://session_tracking.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload, "\t"))
		file.close()
		print("Données exportées dans res://session_tracking.json")

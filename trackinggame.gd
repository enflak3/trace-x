extends Node2D

var tracking_target_scene: PackedScene = preload("res://targettracking.tscn")

const COUNTDOWN_DURATION_SEC: float = 3.0
const SESSION_DURATION_SEC: float = 15.0

var countdown_remaining: float = COUNTDOWN_DURATION_SEC
var is_counting_down: bool = false
var countdown_label: Label = null

var time_elapsed: float = 0.0
var active_target: Area2D = null
var session_active: bool = false

func _ready() -> void:
	_setup_countdown_ui()
	prepare_tracking_session()

func _setup_countdown_ui() -> void:
	var hud_layer = CanvasLayer.new()
	add_child(hud_layer)
	
	countdown_label = Label.new()
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.add_theme_font_size_override("font_size", 64)
	countdown_label.set_anchors_preset(Control.PRESET_CENTER)
	countdown_label.offset_left = -100
	countdown_label.offset_right = 100
	countdown_label.offset_top = -150
	countdown_label.offset_bottom = -70
	hud_layer.add_child(countdown_label)

func _process(delta: float) -> void:
	if is_counting_down:
		countdown_remaining -= delta
		if countdown_remaining > 0.0:
			countdown_label.text = str(ceil(countdown_remaining))
		else:
			is_counting_down = false
			countdown_label.visible = false
			start_tracking_session()
		return

	if not session_active:
		return
		
	time_elapsed += delta
	if time_elapsed >= SESSION_DURATION_SEC:
		finish_tracking_session()

func prepare_tracking_session() -> void:
	time_elapsed = 0.0
	session_active = false
	
	# Instancie et affiche la boule immobile au centre dès le début des 3 secondes
	active_target = tracking_target_scene.instantiate()
	var preset = Sessionmanager.TRACKING_PRESETS.get(
		Sessionmanager.tracking_difficulty,
		Sessionmanager.TRACKING_PRESETS["medium"]
	)
	active_target.apply_difficulty(preset)
	active_target.position = get_viewport_rect().size / 2.0
	add_child(active_target)
	
	countdown_remaining = COUNTDOWN_DURATION_SEC
	is_counting_down = true
	countdown_label.visible = true
	countdown_label.text = str(int(COUNTDOWN_DURATION_SEC))

func start_tracking_session() -> void:
	session_active = true
	active_target.start_moving()
	print("--- SESSION TRACKING DÉMARRÉE (15 s | Difficulté : ", Sessionmanager.tracking_difficulty, ") ---")

func finish_tracking_session() -> void:
	session_active = false
	# Clôture proprement le temps si le curseur est encore sur la cible à la fin des 15s
	if active_target.is_hovered:
		var now = Time.get_ticks_msec()
		active_target.tracked_time_msec += (now - active_target.last_enter_time)
		active_target.is_hovered = false

	var total_time_ms = int(SESSION_DURATION_SEC * 1000.0)
	var tracked_ms = active_target.tracked_time_msec
	var tracking_ratio = clamp((float(tracked_ms) / float(total_time_ms)) * 100.0, 0.0, 100.0)
	
	var samples = active_target.distance_samples
	var avg_distance: float = 0.0
	if not samples.is_empty():
		var total_dist: float = 0.0
		for dist in samples:
			total_dist += dist
		avg_distance = total_dist / float(samples.size())
	
	var tracking_metrics = {
		"difficulty": Sessionmanager.tracking_difficulty,
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
	get_tree().change_scene_to_file("res://resultscreen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu.tscn")

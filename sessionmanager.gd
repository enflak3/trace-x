extends Node

var target_count_setting: int = 10
var tracking_difficulty: String = "medium"

const TRACKING_PRESETS: Dictionary = {
	"easy": {
		"max_speed": 250.0,
		"acceleration": 3.0,
		"target_scale": 1.25,
		"strafe_min": 0.9,
		"strafe_max": 1.8
	},
	"medium": {
		"max_speed": 380.0,
		"acceleration": 4.5,
		"target_scale": 1.0,
		"strafe_min": 0.5,
		"strafe_max": 1.3
	},
	"hard": {
		"max_speed": 540.0,
		"acceleration": 7.5,
		"target_scale": 0.75,
		"strafe_min": 0.25,
		"strafe_max": 0.75
	}
}

var history: Array = []

# Overlay FPS global
var fps_label: Label = null
var show_fps: bool = false

func _ready() -> void:
	# CanvasLayer indépendant pour que l'overlay reste par-dessus toutes les scènes
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128
	add_child(canvas_layer)
	
	fps_label = Label.new()
	fps_label.visible = false
	fps_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	fps_label.offset_left = -90
	fps_label.offset_top = -30
	fps_label.offset_right = -10
	fps_label.offset_bottom = -10
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fps_label.modulate = Color(1, 1, 1, 0.7)
	canvas_layer.add_child(fps_label)

func _process(_delta: float) -> void:
	if show_fps and fps_label:
		fps_label.text = str(Engine.get_frames_per_second()) + " FPS"

func set_fps_display(enabled: bool) -> void:
	show_fps = enabled
	if fps_label:
		fps_label.visible = enabled

func set_fps_limit(limit: int) -> void:
	Engine.max_fps = limit

func save_session(mode_name: String, metrics: Dictionary) -> void:
	var entry = {
		"mode": mode_name,
		"metrics": metrics,
		"timestamp": Time.get_datetime_string_from_system()
	}
	history.append(entry)
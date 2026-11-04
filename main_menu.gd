extends Control

# Menu principal
@onready var main_vbox: VBoxContainer = $VBoxContainer
@onready var btn_flick: Button = $VBoxContainer/BtnFlick
@onready var btn_tracking: Button = $VBoxContainer/BtnTracking

# Sélecteur de cibles Flick
@onready var flick_panel: PanelContainer = $FlickSelectPanel
@onready var btn_10: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn10
@onready var btn_25: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn25
@onready var btn_50: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn50
@onready var btn_back_flick: Button = $FlickSelectPanel/VBoxContainer/BtnBack

# Sélecteur de difficulté Tracking
@onready var tracking_panel: PanelContainer = $TrackingSelectPanel
@onready var btn_easy: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnEasy
@onready var btn_medium: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnMedium
@onready var btn_hard: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnHard
@onready var btn_back_tracking: Button = $TrackingSelectPanel/VBoxContainer/BtnBack

func _ready() -> void:
	flick_panel.visible = false
	tracking_panel.visible = false

	# Connexions boutons du menu
	btn_flick.pressed.connect(_on_flick_pressed)
	btn_tracking.pressed.connect(_on_tracking_pressed)

	# Connexions sélecteur de cibles Flick
	btn_10.pressed.connect(func(): _start_flick(10))
	btn_25.pressed.connect(func(): _start_flick(25))
	btn_50.pressed.connect(func(): _start_flick(50))
	btn_back_flick.pressed.connect(_on_back_from_flick)

	# Connexions sélecteur de difficulté Tracking
	btn_easy.pressed.connect(func(): _start_tracking("easy"))
	btn_medium.pressed.connect(func(): _start_tracking("medium"))
	btn_hard.pressed.connect(func(): _start_tracking("hard"))
	btn_back_tracking.pressed.connect(_on_back_from_tracking)

# --- Navigation Flick ---
func _on_flick_pressed() -> void:
	main_vbox.visible = false
	flick_panel.visible = true

func _on_back_from_flick() -> void:
	flick_panel.visible = false
	main_vbox.visible = true

func _start_flick(count: int) -> void:
	Sessionmanager.target_count_setting = count
	get_tree().change_scene_to_file("res://Main.tscn")

# --- Navigation Tracking ---
func _on_tracking_pressed() -> void:
	main_vbox.visible = false
	tracking_panel.visible = true

func _on_back_from_tracking() -> void:
	tracking_panel.visible = false
	main_vbox.visible = true

func _start_tracking(difficulty: String) -> void:
	Sessionmanager.tracking_difficulty = difficulty
	get_tree().change_scene_to_file("res://trackinggame.tscn")

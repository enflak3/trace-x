extends Control

# Menu principal
@onready var main_vbox: VBoxContainer = $VBoxContainer
@onready var btn_flick: Button = $VBoxContainer/BtnFlick
@onready var btn_tracking: Button = $VBoxContainer/BtnTracking
@onready var btn_settings: Button = $BtnSettings
@onready var btn_quit: Button = $VBoxContainer/BtnQuit

# Sélecteur Flick
@onready var flick_panel: PanelContainer = $FlickSelectPanel
@onready var btn_10: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn10
@onready var btn_25: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn25
@onready var btn_50: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn50
@onready var btn_back_flick: Button = $FlickSelectPanel/VBoxContainer/BtnBack

# Sélecteur Tracking
@onready var tracking_panel: PanelContainer = $TrackingSelectPanel
@onready var btn_easy: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnEasy
@onready var btn_medium: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnMedium
@onready var btn_hard: Button = $TrackingSelectPanel/VBoxContainer/HBoxContainer/BtnHard
@onready var btn_back_tracking: Button = $TrackingSelectPanel/VBoxContainer/BtnBack

# Panneau Paramètres
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var check_fullscreen: BaseButton = $SettingsPanel/VBoxContainer/CheckFullscreen
@onready var btn_fps_limit: OptionButton = $SettingsPanel/VBoxContainer/HBoxContainer/BtnFPSLimit
@onready var btn_show_fps: BaseButton = $SettingsPanel/VBoxContainer/BtnShowFPS
@onready var btn_close: Button = $SettingsPanel/VBoxContainer/BtnClose

var fps_values: Array[int] = [0, 30, 60, 120, 144, 165, 240, 360]

func _ready() -> void:
	# Fallback si BtnQuit ou BtnSettings ont été placés ailleurs
	if not btn_settings:
		btn_settings = get_node_or_null("VBoxContainer/BtnSettings")
	if not btn_quit:
		btn_quit = get_node_or_null("BtnQuit")

	flick_panel.visible = false
	tracking_panel.visible = false
	settings_panel.visible = false

	# Connexions du menu principal
	btn_flick.pressed.connect(_on_flick_pressed)
	btn_tracking.pressed.connect(_on_tracking_pressed)
	if btn_settings:
		btn_settings.pressed.connect(_on_settings_pressed)
	if btn_quit:
		btn_quit.pressed.connect(func(): get_tree().quit())

	# Connexions Flick
	btn_10.pressed.connect(func(): _start_flick(10))
	btn_25.pressed.connect(func(): _start_flick(25))
	btn_50.pressed.connect(func(): _start_flick(50))
	btn_back_flick.pressed.connect(_on_back_from_flick)

	# Connexions Tracking
	btn_easy.pressed.connect(func(): _start_tracking("easy"))
	btn_medium.pressed.connect(func(): _start_tracking("medium"))
	btn_hard.pressed.connect(func(): _start_tracking("hard"))
	btn_back_tracking.pressed.connect(_on_back_from_tracking)

	_setup_settings_ui()

func _setup_settings_ui() -> void:
	# 1. Plein écran
	var mode = DisplayServer.window_get_mode()
	check_fullscreen.button_pressed = (
		mode == DisplayServer.WINDOW_MODE_FULLSCREEN or
		mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	check_fullscreen.toggled.connect(_on_fullscreen_toggled)

	# 2. Liste déroulante Limite FPS
	btn_fps_limit.clear()
	btn_fps_limit.add_item("Illimité")
	btn_fps_limit.add_item("30 FPS")
	btn_fps_limit.add_item("60 FPS")
	btn_fps_limit.add_item("120 FPS")
	btn_fps_limit.add_item("144 FPS")
	btn_fps_limit.add_item("165 FPS")
	btn_fps_limit.add_item("240 FPS")
	btn_fps_limit.add_item("360 FPS")

	var current_fps = Engine.max_fps
	var idx = fps_values.find(current_fps)
	btn_fps_limit.selected = idx if idx != -1 else 0
	btn_fps_limit.item_selected.connect(_on_fps_selected)

	# 3. Afficher les FPS
	btn_show_fps.button_pressed = Sessionmanager.show_fps
	btn_show_fps.toggled.connect(_on_show_fps_toggled)

	# 4. Bouton Fermer
	btn_close.pressed.connect(_on_close_settings_pressed)

# --- Actions Paramètres ---
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fps_selected(index: int) -> void:
	Sessionmanager.set_fps_limit(fps_values[index])

func _on_show_fps_toggled(toggled_on: bool) -> void:
	Sessionmanager.set_fps_display(toggled_on)

# --- Navigation ---
func _on_settings_pressed() -> void:
	main_vbox.visible = false
	if btn_settings:
		btn_settings.visible = false
	settings_panel.visible = true

func _on_close_settings_pressed() -> void:
	settings_panel.visible = false
	main_vbox.visible = true
	if btn_settings:
		btn_settings.visible = true

func _on_flick_pressed() -> void:
	main_vbox.visible = false
	if btn_settings:
		btn_settings.visible = false
	flick_panel.visible = true

func _on_back_from_flick() -> void:
	flick_panel.visible = false
	main_vbox.visible = true
	if btn_settings:
		btn_settings.visible = true

func _start_flick(count: int) -> void:
	Sessionmanager.target_count_setting = count
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_tracking_pressed() -> void:
	main_vbox.visible = false
	if btn_settings:
		btn_settings.visible = false
	tracking_panel.visible = true

func _on_back_from_tracking() -> void:
	tracking_panel.visible = false
	main_vbox.visible = true
	if btn_settings:
		btn_settings.visible = true

func _start_tracking(difficulty: String) -> void:
	Sessionmanager.tracking_difficulty = difficulty
	get_tree().change_scene_to_file("res://trackinggame.tscn")

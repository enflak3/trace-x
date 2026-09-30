extends Control

# Menu principal
@onready var main_vbox: VBoxContainer = $VBoxContainer
@onready var btn_flick: Button = $VBoxContainer/BtnFlick
@onready var btn_tracking: Button = $VBoxContainer/BtnTracking
@onready var btn_settings: Button = $BtnSettings

# Sélecteur de cibles Flick
@onready var flick_panel: PanelContainer = $FlickSelectPanel
@onready var btn_10: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn10
@onready var btn_25: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn25
@onready var btn_50: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn50
@onready var btn_back: Button = $FlickSelectPanel/VBoxContainer/BtnBack

# Menu Paramètres
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var check_fullscreen: CheckButton = $SettingsPanel/VBoxContainer/CheckFullscreen
@onready var option_fps: OptionButton = $SettingsPanel/VBoxContainer/HBoxContainer/OptionFps
@onready var check_show_fps: CheckButton = $SettingsPanel/VBoxContainer/CheckShowFps
@onready var btn_close_settings: Button = $SettingsPanel/VBoxContainer/BtnCloseSettings

var fps_values: Array[int] = [0, 30, 60, 120, 144, 165, 240, 360]

func _ready() -> void:
	flick_panel.visible = false
	settings_panel.visible = false
	
	# Initialisation Plein écran
	var current_mode = DisplayServer.window_get_mode()
	check_fullscreen.button_pressed = (
		current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or 
		current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	)
	
	# Remplissage de la liste déroulante FPS
	option_fps.clear()
	option_fps.add_item("Illimité")
	option_fps.add_item("30 FPS")
	option_fps.add_item("60 FPS")
	option_fps.add_item("120 FPS")
	option_fps.add_item("144 FPS")
	option_fps.add_item("165 FPS")
	option_fps.add_item("240 FPS")
	option_fps.add_item("360 FPS")
	
	var current_fps_limit = Engine.max_fps
	var selected_idx = fps_values.find(current_fps_limit)
	option_fps.selected = selected_idx if selected_idx != -1 else 0

	# Initialisation Affichage FPS
	check_show_fps.button_pressed = Sessionmanager.show_fps

	# Connexions boutons du menu
	btn_flick.pressed.connect(_on_flick_pressed)
	btn_tracking.pressed.connect(_on_tracking_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)

	# Connexions sélecteur de cibles
	btn_10.pressed.connect(func(): _start_flick(10))
	btn_25.pressed.connect(func(): _start_flick(25))
	btn_50.pressed.connect(func(): _start_flick(50))
	btn_back.pressed.connect(_on_back_from_flick)

	# Connexions panneau paramètres
	check_fullscreen.toggled.connect(_on_fullscreen_toggled)
	option_fps.item_selected.connect(_on_fps_selected)
	check_show_fps.toggled.connect(_on_show_fps_toggled)
	btn_close_settings.pressed.connect(_on_close_settings_pressed)

# Navigation
func _on_flick_pressed() -> void:
	main_vbox.visible = false
	btn_settings.visible = false
	flick_panel.visible = true

func _on_back_from_flick() -> void:
	flick_panel.visible = false
	main_vbox.visible = true
	btn_settings.visible = true

func _start_flick(count: int) -> void:
	Sessionmanager.target_count_setting = count
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_tracking_pressed() -> void:
	get_tree().change_scene_to_file("res://TrackingGame.tscn")

func _on_settings_pressed() -> void:
	main_vbox.visible = false
	btn_settings.visible = false
	settings_panel.visible = true

func _on_close_settings_pressed() -> void:
	settings_panel.visible = false
	main_vbox.visible = true
	btn_settings.visible = true

# Actions Paramètres
func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_fps_selected(index: int) -> void:
	Sessionmanager.set_fps_limit(fps_values[index])

func _on_show_fps_toggled(toggled_on: bool) -> void:
	Sessionmanager.set_fps_display(toggled_on)

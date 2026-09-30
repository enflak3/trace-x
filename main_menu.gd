extends Control

@onready var btn_flick: Button = $VBoxContainer/BtnFlick
@onready var btn_tracking: Button = $VBoxContainer/BtnTracking
@onready var main_vbox: VBoxContainer = $VBoxContainer

# Éléments du sous-panneau
@onready var flick_panel: PanelContainer = $FlickSelectPanel
@onready var btn_10: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn10
@onready var btn_25: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn25
@onready var btn_50: Button = $FlickSelectPanel/VBoxContainer/HBoxContainer/Btn50
@onready var btn_back: Button = $FlickSelectPanel/VBoxContainer/BtnBack

func _ready() -> void:
	flick_panel.visible = false
	
	btn_flick.pressed.connect(_on_flick_pressed)
	btn_tracking.pressed.connect(_on_tracking_pressed)
	
	btn_10.pressed.connect(func(): _start_flick(10))
	btn_25.pressed.connect(func(): _start_flick(25))
	btn_50.pressed.connect(func(): _start_flick(50))
	
	btn_back.pressed.connect(func():
		flick_panel.visible = false
		main_vbox.visible = true
	)

func _on_flick_pressed() -> void:
	main_vbox.visible = false
	flick_panel.visible = true

func _on_tracking_pressed() -> void:
	get_tree().change_scene_to_file("res://TrackingGame.tscn")

func _start_flick(count: int) -> void:
	Sessionmanager.target_count_setting = count
	get_tree().change_scene_to_file("res://Main.tscn")

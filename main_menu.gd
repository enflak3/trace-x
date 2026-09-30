extends Control

func _on_btn_flick_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_btn_tracking_pressed() -> void:
	get_tree().change_scene_to_file("res://TrackingGame.tscn")

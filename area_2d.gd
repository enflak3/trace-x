extends Area2D

var spawn_time: int = 0

func _ready() -> void:
	spawn_time = Time.get_ticks_msec()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit_time: int = Time.get_ticks_msec()
		var reaction_time: int = hit_time - spawn_time
		print("Temps de réaction : ", reaction_time, " ms | Position : ", position)
		queue_free()

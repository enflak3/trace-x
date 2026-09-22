extends Area2D

signal target_hit(reaction_time: int, target_pos: Vector2, click_pos: Vector2)

var spawn_time: int = 0

func _ready() -> void:
	spawn_time = Time.get_ticks_msec()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit_time: int = Time.get_ticks_msec()
		var reaction_time: int = hit_time - spawn_time
		var click_pos: Vector2 = get_global_mouse_position()
		
		target_hit.emit(reaction_time, position, click_pos)
		queue_free()

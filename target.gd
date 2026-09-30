extends Area2D

signal target_hit(reaction_time: int, target_pos: Vector2, click_pos: Vector2)

var spawn_time: int = 0
var was_hit: bool = false

func _ready() -> void:
	spawn_time = Time.get_ticks_msec()

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if was_hit:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		was_hit = true
		get_viewport().set_input_as_handled()
		var hit_time: int = Time.get_ticks_msec()
		target_hit.emit(hit_time - spawn_time, position, get_global_mouse_position())
		queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	_input_event(viewport as Viewport, event, shape_idx)

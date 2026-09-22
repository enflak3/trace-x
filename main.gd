extends Node2D

var target_scene: PackedScene = preload("res://Target.tscn")

func _ready() -> void:
	spawn_target()

func spawn_target() -> void:
	var target = target_scene.instantiate()
	
	var screen_size = get_viewport_rect().size
	var margin = 64.0
	
	var rand_x = randf_range(margin, screen_size.x - margin)
	var rand_y = randf_range(margin, screen_size.y - margin)
	target.position = Vector2(rand_x, rand_y)
	
	# Quand la cible disparaît, on en crée une nouvelle
	target.tree_exited.connect(spawn_target)
	
	add_child(target)

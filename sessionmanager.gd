extends Node

const SAVE_PATH: String = "user://session_history.json"

# Tableau contenant l'historique complet des sessions
var history: Array = []
var target_count_setting: int = 10

func _ready() -> void:
	load_history()

func save_session(mode_name: String, session_metrics: Dictionary) -> void:
	var session_entry = {
		"session_id": history.size() + 1,
		"mode": mode_name,
		"timestamp_unix": Time.get_unix_time_from_system(),
		"datetime_iso": Time.get_datetime_string_from_system(false, true),
		"display_resolution": {
			"width": get_viewport().get_visible_rect().size.x,
			"height": get_viewport().get_visible_rect().size.y
		},
		"metrics": session_metrics
	}
	
	history.append(session_entry)
	write_to_disk()
	print("[SessionManager] Session #", session_entry["session_id"], " (", mode_name, ") sauvegardée.")

func write_to_disk() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(history, "\t"))
		file.close()
	else:
		printerr("[SessionManager] Erreur lors de l'ouverture du fichier en écriture.")

func load_history() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		history = []
		return
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(content)
		if parsed is Array:
			history = parsed
		else:
			history = []

func get_sessions_by_mode(mode_name: String) -> Array:
	return history.filter(func(s): return s["mode"] == mode_name)

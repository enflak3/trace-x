extends Control

@onready var mode_title: Label = $PanelContainer/VBoxContainer/modetitle
@onready var grade_label: Label = $PanelContainer/VBoxContainer/gradelabel
@onready var accuracy_label: Label = $PanelContainer/VBoxContainer/accuracylabel
@onready var stat1: Label = $PanelContainer/VBoxContainer/statscontainer/stat1
@onready var stat2: Label = $PanelContainer/VBoxContainer/statscontainer/stat2
@onready var stat3: Label = $PanelContainer/VBoxContainer/statscontainer/stat3

@onready var retry_button: Button = $PanelContainer/VBoxContainer/buttoncontainer/retrybutton
@onready var menu_button: Button = $PanelContainer/VBoxContainer/buttoncontainer/menubutton

var last_mode: String = ""

const DIFFICULTY_LABELS: Dictionary = {
	"easy": "Facile",
	"medium": "Moyen",
	"hard": "Difficile"
}

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	display_last_results()

func display_last_results() -> void:
	if Sessionmanager.history.is_empty():
		return
		
	var session = Sessionmanager.history[-1]
	last_mode = session["mode"]
	var metrics = session["metrics"]
	
	if last_mode == "flick":
		var total_targets = int(metrics.get("total_targets", Sessionmanager.target_count_setting))
		mode_title.text = "RÉSULTATS - FLICKING (" + str(total_targets) + " CIBLES)"
		
		# On affiche le taux de réussite brut comme précision principale (pour la note SS/S/A/...)
		var hit_rate = float(metrics.get("hit_rate_pct", 0.0))
		var centering = float(metrics.get("centering_pct", 0.0))
		
		accuracy_label.text = "Taux de réussite : " + str(hit_rate) + " %"
		grade_label.text = calculate_grade(hit_rate)
		
		# Calcul des moyennes complémentaires
		var shots: Array = metrics.get("shots", [])
		var avg_react = 0.0
		var avg_eff = 0.0
		for shot in shots:
			avg_react += shot.get("reaction_time_ms", 0.0)
			avg_eff += shot.get("path_efficiency", 0.0)
			
		if not shots.is_empty():
			avg_react /= float(shots.size())
			avg_eff /= float(shots.size())
			
		stat1.text = "Précision centrage : " + str(centering) + " %"
		stat2.text = "Temps de réaction : " + str(snapped(avg_react, 1.0)) + " ms"
		stat3.text = "Efficacité trajectoire : " + str(snapped(avg_eff * 100.0, 0.1)) + " %"
		
	elif last_mode == "tracking":
		var raw_diff: String = metrics.get("difficulty", Sessionmanager.tracking_difficulty)
		var diff_label: String = DIFFICULTY_LABELS.get(raw_diff, raw_diff.capitalize())
		
		mode_title.text = "RÉSULTATS - TRACKING (" + diff_label.to_upper() + ")"
		var tot = float(metrics["time_on_target_pct"])
		accuracy_label.text = "Time on Target : " + str(tot) + " %"
		grade_label.text = calculate_grade(tot)
		
		var avg_offset = float(metrics.get("avg_offset_px", 0.0))
		# Score de centrage : 100% si parfaitement au centre, décroît avec la dérive
		var centering_score = clamp(100.0 - (avg_offset * 1.5), 0.0, 100.0)
		
		stat1.text = "Précision de centrage : " + str(snapped(centering_score, 0.1)) + " %"
		stat2.text = "Dérive moyenne : " + str(avg_offset) + " px"
		stat3.text = "Difficulté : " + diff_label + " (" + str(int(metrics["duration_sec"])) + " s)"

	# Code couleur osu! pour le grade
	match grade_label.text:
		"SS": grade_label.modulate = Color("ffd700") # Or
		"S": grade_label.modulate = Color("e0af00")
		"A": grade_label.modulate = Color("4cd964") # Vert
		"B": grade_label.modulate = Color("34aadc") # Bleu
		"C": grade_label.modulate = Color("ff9500") # Orange
		_: grade_label.modulate = Color("ff3b30")   # Rouge (D)

func calculate_grade(score_pct: float) -> String:
	if score_pct >= 99.0:
		return "SS"
	elif score_pct >= 95.0:
		return "S"
	elif score_pct >= 90.0:
		return "A"
	elif score_pct >= 80.0:
		return "B"
	elif score_pct >= 70.0:
		return "C"
	else:
		return "D"

func _on_retry_pressed() -> void:
	if last_mode == "flick":
		get_tree().change_scene_to_file("res://Main.tscn")
	elif last_mode == "tracking":
		get_tree().change_scene_to_file("res://trackinggame.tscn")

func _on_menu_pressed() -> void:
	if ResourceLoader.exists("res://main_menu.tscn"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		print("Pas encore de MainMenu.tscn défini !")

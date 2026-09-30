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
		mode_title.text = "RÉSULTATS - FLICKING"
		var acc = float(metrics["accuracy_pct"])
		accuracy_label.text = "Précision : " + str(acc) + " %"
		grade_label.text = calculate_grade(acc)
		
		# Calcul des moyennes du run
		var shots: Array = metrics.get("shots", [])
		var avg_react = 0.0
		var avg_eff = 0.0
		var total_corrections = 0
		for shot in shots:
			avg_react += shot["reaction_time_ms"]
			avg_eff += shot["path_efficiency"]
			total_corrections += shot.get("micro_corrections", 0)
			
		if not shots.is_empty():
			avg_react /= float(shots.size())
			avg_eff /= float(shots.size())
			
		stat1.text = "Temps de réaction moyen : " + str(snapped(avg_react, 1.0)) + " ms"
		stat2.text = "Efficacité trajectoire : " + str(snapped(avg_eff * 100.0, 0.1)) + " %"
		stat3.text = "Micro-corrections totales : " + str(total_corrections)
		
	elif last_mode == "tracking":
		mode_title.text = "RÉSULTATS - TRACKING"
		var tot = float(metrics["time_on_target_pct"])
		accuracy_label.text = "Time on Target : " + str(tot) + " %"
		grade_label.text = calculate_grade(tot)
		
		var avg_offset = float(metrics.get("avg_offset_px", 0.0))
		# Score de centrage : 100% si parfaitement au centre, décroît avec la dérive
		var centering_score = clamp(100.0 - (avg_offset * 1.5), 0.0, 100.0)
		
		stat1.text = "Précision de centrage : " + str(snapped(centering_score, 0.1)) + " %"
		stat2.text = "Dérive moyenne : " + str(avg_offset) + " px"
		stat3.text = "Durée du test : " + str(metrics["duration_sec"]) + " s"

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
		get_tree().change_scene_to_file("res://TrackingGame.tscn")

func _on_menu_pressed() -> void:
	# Si votre binôme a fait un MainMenu.tscn, sinon recharge le jeu
	if ResourceLoader.exists("res://main_menu.tscn"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	else:
		print("Pas encore de MainMenu.tscn défini !")

extends Control

func _ready():
	pass

func _on_StartButton_pressed():
	var err := get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
	if err != OK:
		push_error("Error cargando escena: %s" % err)

func _on_QuitButton_pressed():
	get_tree().quit()

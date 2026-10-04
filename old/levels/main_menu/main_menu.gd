extends Node2D

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/level_test/level_test.tscn")

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_authors_pressed() -> void:
	$credits.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

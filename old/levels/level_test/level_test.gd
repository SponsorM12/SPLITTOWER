extends Node2D

#get_tree().paused = true
# $pausemenu.visible = true

func _on_continue_pressed() -> void:
	$menu.visible = false
	get_tree().paused = false
  
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	print("Открыть настройки")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/main_menu/main_menu.tscn")
	#get_tree().paused = false

extends Control

var main: Node2D

func _ready() -> void:
	hide()

func _on_resume_pressed() -> void:
	main.handle_pause()


func _on_save_pressed() -> void:
	main.handle_save()


func _on_quit_pressed() -> void:
	main.handle_quit()

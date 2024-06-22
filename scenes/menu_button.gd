extends Button


func _on_toggled(toggled_on):
	Game.main.play_sfx()
	$Menu.visible = toggled_on

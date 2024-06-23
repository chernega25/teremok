class_name Main
extends Control

@export var _background_scale : Vector2 = Vector2(1.5, 1.5)
@export var _levels : Array[PackedScene] = [preload("res://scenes/levels/grid.tscn")]
var _current_level : int = -1
var _grid : Node
var _position_speed : Vector2
var _scale_speed : Vector2
var _item_menu : Array[ItemBox]

func _can_drop_data(_at_position:Vector2, _data:Variant)->bool:
	return true

func _drop_data(_at_position:Vector2, data:Variant)->void:
	_grid.put_item(data)
	data.item.queue_free()

func delete_data(data:Variant)->void:
	_drop_data(Vector2.ZERO, data)

func _ready():
	Game.main = self
	Game.rotate_signal = $ItemMenu/Buttons/RotateButton.pressed
	Game.flip_signal = $ItemMenu/Buttons/FlipButton.pressed
	
	_position_speed = $BackgroundPlace.position / $StartAnimationTimer.wait_time
	_scale_speed = _background_scale / $StartAnimationTimer.wait_time
	_item_menu = [$ItemMenu/Items/ItemBox, 
					$ItemMenu/Items/ItemBox2, 
					$ItemMenu/Items/ItemBox3, 
					$ItemMenu/Items/ItemBox4, 
					$ItemMenu/Items/ItemBox5, 
					$ItemMenu/Items/ItemBox6]

func _process(delta):
	if !$StartAnimationTimer.is_stopped():
		$Background.position += delta * _position_speed
		$Background.scale += delta * _scale_speed

func _adjust_scale():
	var grid_size = _grid.object_size
	var grid_max_side = max(grid_size.x, grid_size.y)
	var grid_scale : float = min($GridPlace.size.x / grid_max_side, 3)
	var grid_offset = $GridPlace.size - (grid_size * grid_scale)
	
	_grid.scale = Vector2(grid_scale, grid_scale)
	_grid.position = $GridPlace.position + (grid_offset / 2)
	
	Game.grid_scale = grid_scale

func _next_level(prev: bool):
	get_viewport().gui_release_focus()
	if prev:
		_current_level -= 1
	else:
		_current_level += 1
	_grid = _levels[_current_level].instantiate() as Grid
	_grid.level_completed.connect(_on_level_completed)
	_grid.wrong_solution.connect(_on_wrong_solution)
	add_child(_grid)
	_adjust_scale()
	
	for i in range(6):
		_item_menu[i]._available(i < _grid.items_available)
		
	$MenuButton/Menu/LevelLabel.text = "level " + str(_current_level + 1)
	
	if _current_level == 0:
		$GameField/Level1TipLabel.visible = true
	if _current_level == 1:
		$GameField/Level2TipLabel.visible = true

func _on_start_button_pressed():
	play_sfx()
	$StartButton.visible = false
	$Labels.visible = false
	
	$StoryPanel.visible = true
	$StoryPanel.start_typing()

func _on_start_animation_timer_timeout():
	$ItemMenu.visible = true
	$MenuButton.visible = true
	_next_level(false)
	
func _on_wrong_solution():
	$GameField/WrongSolutionLabel.visible = true
	$WrongSolutionTimer.start()
	
func _on_skip():
	$GameField/Level1TipLabel.visible = false
	$GameField/Level2TipLabel.visible = false
	$GameField/WrongSolutionLabel.visible = false
	
	if _current_level < _levels.size() - 1:
		_grid.queue_free()
		_next_level(false)
		
func _on_prev():
	$GameField/Level1TipLabel.visible = false
	$GameField/Level2TipLabel.visible = false
	$GameField/WrongSolutionLabel.visible = false
	
	if _current_level > 0:
		_grid.queue_free()
		_next_level(true)

func _on_level_completed():
	$GameField/Level1TipLabel.visible = false
	$GameField/Level2TipLabel.visible = false
	$GameField/WrongSolutionLabel.visible = false
	
	$GameField/LevelEndScreen.visible = true
	if _current_level == _levels.size() - 1:
		$GameField/EndGameLabel.visible = true
		$GameField/EndGameButton.visible = true
	else:
		$GameField/NextLevelLabel.visible = true
		$GameField/NextLevelButton.visible = true

func _on_next_level_button_pressed():
	play_sfx()
	_grid.queue_free()
	_next_level(false)
	$GameField/LevelEndScreen.visible = false
	$GameField/NextLevelLabel.visible = false
	$GameField/NextLevelButton.visible = false

func _on_end_game_button_pressed():
	play_sfx()
	_grid.queue_free()
	$Background.position = Vector2.ZERO
	$Background.scale = Vector2.ONE
	$ItemMenu.visible = false
	$StartButton.visible = true
	$Labels.visible = true
	_current_level = -1
	
	$MenuButton.visible = false
	
	$GameField/Level1TipLabel.visible = false
	$GameField/Level2TipLabel.visible = false
	$GameField/WrongSolutionLabel.visible = false
	
	$GameField/LevelEndScreen.visible = false
	$GameField/EndGameLabel.visible = false
	$GameField/EndGameButton.visible = false


func _on_wrong_solution_timer_timeout():
	$GameField/WrongSolutionLabel.visible = false


func _on_continue_button_pressed():
	play_sfx()
	$StoryPanel.visible = false
	$StartAnimationTimer.start()

func play_sfx():
	$ButtonSFX.play()

func _notification(what):
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			Game.mouse_on_screen = true
		NOTIFICATION_WM_MOUSE_EXIT:
			Game.mouse_on_screen = false


func _on_delete_button_pressed():
	play_sfx()
	_grid.delete_all()


func _on_skip_button_pressed():
	play_sfx()
	_on_skip()

func _on_main_menu_button_pressed():
	_on_end_game_button_pressed()


func _on_previous_button_pressed():
	play_sfx()
	_on_prev()

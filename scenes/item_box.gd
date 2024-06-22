class_name ItemBox
extends Panel

var _focused : bool = false

var _center_pos : Vector2
var _item_scale : float

var _focused_style : StyleBox


func _ready():
	if $Item:
		_item_scale = (size.y * 0.7) / max($Item.size.x, $Item.size.y)
		_center_pos = Vector2(size.x / 2, size.y * 0.6)
		$Item.scale = Vector2(_item_scale, _item_scale)
		$Item.position = _center_pos - ($Item.size * _item_scale / 2)
	
	_focused_style = theme.get_stylebox("panel_focus", "Panel")

func _process(_delta):
	pass


func _on_focus_entered():
	_focused = true
	add_theme_stylebox_override("panel", _focused_style)


func _on_focus_exited():
	_focused = false
	remove_theme_stylebox_override("panel")


func _on_rotate_button_pressed():
	if !_focused: return
	if !$Item: return
	
	Game.main.play_sfx()
	$Item.rotate(false)
	$Item.position = _center_pos - ($Item.size * _item_scale / 2)


func _on_flip_button_pressed():
	if !_focused: return
	if !$Item: return
	
	Game.main.play_sfx()
	$Item.flip(false)
	
func _available(on : bool)->void:
	focus_mode = Control.FOCUS_ALL if on else FOCUS_NONE
	$Item/ItemOffset/Animal.material.set_shader_parameter("on", !on)
	$Name.visible = on
	$Item.mouse_filter = MOUSE_FILTER_PASS if on else MOUSE_FILTER_IGNORE

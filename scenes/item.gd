class_name Item
extends Control

@export var item_number : int = -1
@export_group("Cells")
@export var _item_size : Vector2i
@export var _original_size : Vector2i
@export var _cells : Array[Vector2i]
var _cell_size : int = 32

var _corners : Array[Vector2i]
var current_corner : int = 0

var _blocks : Array[Node]


func _ready():
	_blocks = $ItemOffset/Blocks.get_children()
	material = material.duplicate()
	
	_corners.clear()
	_corners.push_back(Vector2i.ZERO)
	_corners.push_back(Vector2i(_original_size.y * _cell_size, 0))
	_corners.push_back(_original_size * _cell_size)
	_corners.push_back(Vector2i(0, _original_size.x * _cell_size))
	#print_debug(self)

func _process(_delta):
	pass
	
func get_cells()->Array[Vector2i]:
	return _cells
	
func _get_drag_data(at_position:Vector2)->Variant:
	#get_viewport().gui_release_focus()
	var node = duplicate()
	add_child(node)
	remove_child(node)
	node.current_corner = current_corner
	
	node.scale = Vector2.ONE
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var drag_data = ItemDrag.new(null, self, node, at_position)
	drag_data.drag_completed.connect(_on_drag_completed)
	
	set_drag_preview(drag_data.preview)
	
	return drag_data

func _on_drag_completed(data : ItemDrag)->void:
	if data.destination == null:
		data.item.queue_free()
		data.preview.queue_free()
	
func item_offset(offset: Vector2)->void:
	$ItemOffset.position = Vector2i(-offset)
	
func _rotate_cell(cell: Vector2i)->Vector2i:
	return Vector2i(-cell.y + _item_size.x - 1, cell.x)
	
func _flip_cell(cell: Vector2i)->Vector2i:
	return Vector2i(-cell.x + _item_size.x - 1, cell.y)
	
func _rotate_offset(pos: Vector2)->Vector2:
	return Vector2(-size.x - pos.y, pos.x)
	
func rotate(offset: bool)->void:
	_item_size = Vector2i(_item_size.y, _item_size.x)
	size = _item_size * _cell_size
	
	for i in range(_cells.size()):
		_cells[i] = _rotate_cell(_cells[i])
		_blocks[i].position = _cells[i] * _cell_size
		
	current_corner = (current_corner + 1) % 4
	$ItemOffset/Animal.rotation_degrees = current_corner * 90
	$ItemOffset/Animal.position = _corners[current_corner]
	
	if offset:
		$ItemOffset.position = _rotate_offset($ItemOffset.position) 
	
func flip(offset: bool)->void:
	for i in range(_cells.size()):
		_cells[i] = _flip_cell(_cells[i])
		_blocks[i].position = _cells[i] * _cell_size
		
	if (current_corner % 2 == 0):
		$ItemOffset/Animal.flip_h = !$ItemOffset/Animal.flip_h
	else:
		$ItemOffset/Animal.flip_v = !$ItemOffset/Animal.flip_v
		
	if offset:
		$ItemOffset.position.x = -size.x - $ItemOffset.position.x
	
func drag(on: bool)->void:
	material.set_shader_parameter("drag", on)
	
func get_item_offset()->Vector2:
	return -$ItemOffset.position










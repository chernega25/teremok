class_name Grid
extends TileMap

signal level_completed
signal wrong_solution

@export var items_available : int = 6

@export var slot_scene : PackedScene

# 4 - 
# 5 + 
# 6 -
# 7 -
# 8 +
# 9 +


var _grid_size : Vector2i
var _max_grid : int
var _slot_array : Array[Slot]
var _item_array : Array[Item]
var _cell_size : int

var object_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	var cells = get_used_cells(0)
	_grid_size = get_used_rect().size
	_max_grid = _grid_size.x * _grid_size.y
	
	_slot_array.resize(_max_grid)
	_item_array.resize(_max_grid)
	
	_cell_size = tile_set.tile_size.x
	
	for cell in cells:
		_slot_array[_translate(cell)] = _create_slot(cell.x, cell.y)
		
	object_size = _grid_size * _cell_size

func _process(_delta):
	if (Input.is_action_just_pressed("save")):
		save()


func _translate(cell: Vector2i)->int:
	return _grid_size.y * cell.x + cell.y
	
func _check_border(cell: Vector2i)->bool:
	return (cell.x >= 0 
		and cell.y >= 0 
		and cell.x < _grid_size.x 
		and cell.y < _grid_size.y)
	
func _create_slot(x: int, y: int)->Slot:
	var node = slot_scene.instantiate() as Slot
	add_child(node)
	node.size.x = _cell_size
	node.size.y = _cell_size
	node.position.x = x * _cell_size
	node.position.y = y * _cell_size
	return node

func _get_item(cell: Vector2i)->Item:
	return _item_array[_translate(cell)]
	
func _set_item(cell: Vector2i, item: Item)->void:
	_item_array[_translate(cell)] = item
	
func _get_slot(cell: Vector2i)->Slot:
	return _slot_array[_translate(cell)]
	
func _get_cell(pos: Vector2)->Vector2i:
	return pos / _cell_size

func get_item(pos: Vector2)->Item:
	return _get_item(_get_cell(pos))
	
func check_item(pos: Vector2, data: ItemDrag)->bool:
	var start = _get_cell(pos) - _get_cell(data.offset)
	var cells = data.item.get_cells()
	
	var ok : bool = true
	for cell in cells:
		var cur = start + cell
		if (!_check_border(cur) 
			or _get_slot(cur) == null 
			or (_get_item(cur) != null 
			and _get_item(cur).get_instance_id() != data.item_source.get_instance_id())): 
			ok = false
			
	return ok

func put_item(data: ItemDrag)->void:
	Game.main.play_sfx()
	
	add_child(data.item)
	if data.source != null:
		var cells1 = data.item_source.get_cells()
		var source = _get_cell(data.item_source.position)
		for cell in cells1:
			var cur = source + cell
			_set_item(cur, null)
		remove_child(data.item_source)
		
	
	if data.destination != null:
		var cells2 = data.item.get_cells()
		var destination = _get_cell(data.destination.position) - _get_cell(data.offset)
		for cell in cells2:
			var cur = destination + cell
			_set_item(cur, data.item)
		
		data.item.position = destination * _cell_size
		
	_check_completion()
		
	
func _check_completion()->void:
	var items : Array[bool] = [0, 0, 0, 0, 0, 0]
	items.resize(items_available)
	
	var ok : bool = true
	for i in range(_max_grid):
		if _slot_array[i]:
			if _item_array[i]:
				items[_item_array[i].item_number] = true
			else:
				ok = false
				break
	
	if !ok: return
	
	for item in items:
		if !item:
			ok = false
			break
			
	if ok:
		level_completed.emit()
	else:
		wrong_solution.emit()

func save():
	var filename : String = "save" + str(randi()) + ".txt"
	var filesave = FileAccess.open("res://saves/" + filename, FileAccess.WRITE_READ)
	
	var data : String = ""
	for i in range(_grid_size.y):
		for j in range(_grid_size.x):
			var item = _get_item(Vector2i(j, i))
			if item:
				data += str(item.item_number + 1)
			else:
				data += '0'
		data += '\n'
	
	filesave.store_line(data)

func delete_all():
	for i in range(_item_array.size()):
		if _item_array[i]:
			_item_array[i].queue_free()
		_item_array[i] = null



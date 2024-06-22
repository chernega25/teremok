class_name ItemDrag

signal drag_completed(data:ItemDrag)

var source: Slot = null
var destination: Slot = null
var offset: Vector2 = Vector2.ZERO

var item_source: Item
var item: Item
var preview: Item

func _init(_source: Control, _item_source: Item, _item: Item, _offset: Vector2):
	self.source = _source
	self.item_source = _item_source
	self.item = _item
	self.offset = _offset
	
	item.drag(true)
	
	self.preview = _item.duplicate()
	self.preview.current_corner = _item.current_corner
	self.preview.scale = Vector2(Game.grid_scale, Game.grid_scale)
	self.preview.item_offset(_offset)
	self.preview.tree_exiting.connect(_on_tree_exiting)
	
	Game.rotate_signal.connect(_on_rotate)
	Game.flip_signal.connect(_on_flip)

func _on_tree_exiting()->void:
	item.drag(false)
	drag_completed.emit(self)

func _on_rotate():
	item.rotate(false)
	preview.rotate(true)
	offset = preview.get_item_offset()
	
func _on_flip():
	item.flip(false)
	preview.flip(true)
	offset = preview.get_item_offset()

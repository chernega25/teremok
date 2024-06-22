class_name Slot
extends Control


func _get_drag_data(at_position:Vector2)->Variant:
	get_viewport().gui_release_focus()
	var node = get_parent().get_item(position)
	if node == null: return null
	
	var node2 = node.duplicate()
	add_child(node2)
	remove_child(node2)
	node2.current_corner = node.current_corner
	
	var drag_data = ItemDrag.new(self, node, node2, at_position + position - node.position)
	drag_data.drag_completed.connect(_on_drag_completed)
	
	set_drag_preview(drag_data.preview)
	
	return drag_data

func _on_drag_completed(data : ItemDrag)->void:
	if data.destination == null:
		if !Game.mouse_on_screen:
			Game.main.delete_data(data)
		data.preview.queue_free()
		

func _can_drop_data(_at_position:Vector2, data:Variant)->bool:
	if !data is ItemDrag: return false
	var drag_data = data as ItemDrag
	
	var res = get_parent().check_item(position, drag_data)
	
	return res


func _drop_data(_at_position:Vector2, data:Variant)->void:
	data.destination = self
	get_parent().put_item(data)













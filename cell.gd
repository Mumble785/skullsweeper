class_name Cell
extends Node

@export var cell_id := Vector2i(0, 0)
var is_skull := false
var hint_val: int

signal on_cell_clicked


func set_value(hint):
	if hint == 9:
		$Skull.visible = true
		is_skull = true
	elif hint > 0:
		$Value.text = str(hint)
		
	hint_val = hint
func _on_button_field_pressed() -> void:
	on_cell_clicked.emit(is_skull, hint_val, cell_id)
	$Fill.visible = false


func auto_click():
	if $Fill.visible:
		$Fill.visible = false
		return true
	else:
		pass


func skulls_win():
	if is_skull:
		$Fill.visible = false

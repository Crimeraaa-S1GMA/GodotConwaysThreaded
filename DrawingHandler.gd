extends Node2D

var last_cell_pos : Vector2i = Vector2i(-1, -1)
var is_mouse_held : bool = false

func _process(delta: float) -> void:
	if is_mouse_held:
		var cell_pos : Vector2i = Vector2i((get_global_mouse_position() / Main.CELL_SIZE).floor()).abs()
		if last_cell_pos != cell_pos:
			Main.drawing_queue.append([cell_pos, true])
		last_cell_pos = cell_pos
	else:
		last_cell_pos = Vector2i(-1, -1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1:
			is_mouse_held = event.pressed

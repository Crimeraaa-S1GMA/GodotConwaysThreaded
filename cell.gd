class_name Cell extends Sprite2D

var cell_pos : Vector2i = Vector2i.ZERO

func _process(delta: float) -> void:
	visible = Main.cells[cell_pos]
	position = Vector2(cell_pos) * Main.CELL_SIZE
	scale = Vector2.ONE * (4 / Main.CELL_SIZE)

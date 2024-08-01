extends Node

@onready var cell_container : CellContainer = %CellContainer

@onready var cell : PackedScene = preload("res://cell.tscn")

const WORLD_SIZE : Vector2i = Vector2i(80, 80)
const CELL_SIZE : float = 8.0

var cells : Dictionary = {}
var old_cells : Dictionary = {}
var drawing_queue : Array = []

var is_working : bool = false
var is_writing_cells : bool = false

func _ready() -> void:
	randomize()
	
	initialize_cells(WORLD_SIZE)

func _process(delta: float) -> void:
	if not is_writing_cells and drawing_queue.size() > 0:
		for i in drawing_queue:
			if cells.has(i[0]):
				cells[i[0]] = i[1]
		drawing_queue.clear()

func initialize_cells(world_size : Vector2i) -> void:
	for child : Node in cell_container.get_children():
		child.queue_free()
	
	cells.clear()
	for x in range(world_size.x):
		for y in range(world_size.y):
			var pos : Vector2i = Vector2i(x, y)
			cells[pos] = false if randi() % 2 == 0 else true
			var cell_ins : Cell = cell.instantiate()
			
			cell_ins.cell_pos = pos
			
			cell_container.add_child(cell_ins)

func get_neighbors(cells_used : Dictionary, pos : Vector2i) -> Array:
	var neighbors : Array = []
	
	var x : int = pos.x
	var y : int = pos.y
	var xplus : int = (pos.x + 1) % WORLD_SIZE.x
	var yplus : int = (pos.y + 1) % WORLD_SIZE.y
	var xmin : int = pos.x - 1
	var ymin : int = pos.y - 1
	if xmin < 0:
		xmin = WORLD_SIZE.x - 1
	if ymin < 0:
		ymin = WORLD_SIZE.y - 1
	
	neighbors.append(cells_used[Vector2i(xplus, y)])
	neighbors.append(cells_used[Vector2i(xmin, y)])
	neighbors.append(cells_used[Vector2i(x, yplus)])
	neighbors.append(cells_used[Vector2i(x, ymin)])
	neighbors.append(cells_used[Vector2i(xplus, yplus)])
	neighbors.append(cells_used[Vector2i(xplus, ymin)])
	neighbors.append(cells_used[Vector2i(xmin, yplus)])
	neighbors.append(cells_used[Vector2i(xmin, ymin)])
	
	return neighbors

func process_cell(cell_index : int) -> void:
	var pos : Vector2i = old_cells.keys()[cell_index]
	var value : bool = old_cells[pos]
	var neighbors : Array = get_neighbors(old_cells, pos)
	
	var live_neighbors : int = 0
	
	for n in neighbors:
		if n:
			live_neighbors += 1
	
	if value:
		if live_neighbors >= 2 && live_neighbors < 4:
			cells[pos] = true
		else:
			cells[pos] = false
	else:
		if live_neighbors == 3:
			cells[pos] = true

func _on_game_process_timer_timeout() -> void:
	if not is_working:
		is_working = true
		while drawing_queue.size() > 0:
			await get_tree().process_frame
		is_writing_cells = true
		old_cells = cells.duplicate(true)
		var task_id : int = WorkerThreadPool.add_group_task(Callable(self, "process_cell"), cells.size(), -1, true)
		while not WorkerThreadPool.is_group_task_completed(task_id):
			await get_tree().process_frame
		WorkerThreadPool.wait_for_group_task_completion(task_id)
		old_cells = {}
		is_writing_cells = false
		is_working = false

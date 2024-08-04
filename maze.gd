@icon("res://maze.png")
class_name Maze
extends RefCounted

var width: int
var height: int
var size: int

var maze: Array[Array] = []
var visited_count: int = 0

## The Wall enum represents the state of a cell in a maze.
## The state combines the walls and the visited flag.
enum Wall {
	NONE = 0,
	UP = 1, DOWN = 2, LEFT = 4, RIGHT = 8,
	ALL = 15,
	NOT_VISITED = 16
}


@warning_ignore("shadowed_variable")
func _init(width: int, height: int) -> void:
	assert(width > 0, "width must be greater than 0")
	assert(height > 0, "height must be greater than 0")
	
	self.width = width
	self.height = height
	size = width * height

	maze.resize(width)
	
	# Initialize maze array
	for x in range(width):
		var maze_column: Array[Wall] = []
		maze_column.resize(height)
		maze_column.fill(Wall.ALL | Wall.NOT_VISITED)
		maze[x] = maze_column
	
	generate_maze()


## Generates a maze using Wilson's algorithm.
func generate_maze() -> void:
	print_maze("initial")

	var start_position = get_random_unvisited_position()
	visit(start_position)

	print_maze("start position %s" % start_position)

	var path_index: int = 0
	var iteration_index: int = 0

	while not is_all_visited():
		var pos = get_random_unvisited_position()
		var path: Array[Vector2i] = [pos]
		

		while true:
			iteration_index += 1

			var neighbor = get_random_neighbor(pos)

			if is_visited(neighbor):
				path.append(neighbor)
				break
			
			# Check for loops in the path
			var loop_index = path.find(neighbor)
			if loop_index != -1:
				path = path.slice(0, loop_index + 1)
				pos = path[path.size() - 1]
				continue


			pos = neighbor
			path.append(pos)


		remove_walls_along_path(path)
		visit_path(path)
		print_maze("path is visited, iteration_index: %s, path_index: %s, path: %s-%s" % [iteration_index, path_index, path[0], path[path.size() - 1]])
		path_index += 1
	
	print_maze("generated, iteration_index: %s, path_index: %s" % [iteration_index, path_index])


func visit_path(path: Array[Vector2i]) -> void:
	for cell in path:
		visit(cell)


func visit(position: Vector2i) -> void:
	if is_visited(position):
		return
	
	unset_state(position, Wall.NOT_VISITED)
	visited_count += 1


func is_visited(position: Vector2i) -> bool:
	return not has_state(position, Wall.NOT_VISITED)


func has_state(position: Vector2i, state: Wall) -> bool:
	return maze[position.x][position.y] & state == state


func set_state(position: Vector2i, state: Wall) -> void:
	maze[position.x][position.y] = maze[position.x][position.y] | state


func unset_state(position: Vector2i, state: Wall) -> void:
	maze[position.x][position.y] = maze[position.x][position.y] & (~state)


func is_all_visited() -> bool:
	return visited_count == size


func get_random_unvisited_position() -> Vector2i:
	var position: Vector2i

	while true:
		position = Vector2i(randi() % width, randi() % height)

		if not is_visited(position):
			break

	return position


func get_random_neighbor(position: Vector2i) -> Vector2i:
	var neighbors: Array[Vector2i] = []
	
	if position.x > 0:
		neighbors.append(Vector2i(position.x - 1, position.y))
	if position.x < width - 1:
		neighbors.append(Vector2i(position.x + 1, position.y))
	if position.y > 0:
		neighbors.append(Vector2i(position.x, position.y - 1))
	if position.y < height - 1:
		neighbors.append(Vector2i(position.x, position.y + 1))

	return neighbors[randi() % neighbors.size()]


func remove_walls_along_path(path: Array[Vector2i]) -> void:
	for i in range(path.size() - 1):
		remove_walls_between_cells(path[i], path[i + 1])


func remove_walls_between_cells(cell1: Vector2i, cell2: Vector2i) -> void:
	var direction = cell2 - cell1
	if direction == Vector2i.UP:
		unset_state(cell1, Wall.UP)
		unset_state(cell2, Wall.DOWN)
	elif direction == Vector2i.DOWN:
		unset_state(cell1, Wall.DOWN)
		unset_state(cell2, Wall.UP)
	elif direction == Vector2i.LEFT:
		unset_state(cell1, Wall.LEFT)
		unset_state(cell2, Wall.RIGHT)
	elif direction == Vector2i.RIGHT:
		unset_state(cell1, Wall.RIGHT)
		unset_state(cell2, Wall.LEFT)
	else:
		assert(false, "Invalid direction between cells")


func print_maze(label: String) -> void:
	print("------------------ maze: %s ------------------" % label)
	var maze_str: String = ""

	# Top border
	maze_str += "+" + "-+".repeat(width) + "\n"
	
	for y in range(height):
		var top_line: String = "|"
		var bottom_line: String = "+"
		for x in range(width):
			# Cell contents
			if is_visited(Vector2i(x, y)):
				top_line += " " # Visited cell
			else:
				top_line += "#" # Unvisited cell
			
			# Right wall
			if has_state(Vector2i(x, y), Wall.RIGHT):
				top_line += "|"
			else:
				top_line += " "
			
			# Bottom wall
			if has_state(Vector2i(x, y), Wall.DOWN):
				bottom_line += "-"
			else:
				bottom_line += " "
			
			bottom_line += "+"
		
		maze_str += top_line + "\n"
		maze_str += bottom_line + "\n"

	print(maze_str)

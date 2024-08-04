extends Node

var maze: Maze

func _ready() -> void:
	maze = MazeGenerator.generate_maze(10, 10)
	maze.print_maze("generated")

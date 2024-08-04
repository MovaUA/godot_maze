extends Node

var maze: Maze

func _ready() -> void:
	maze = MazeGenerator.generate_maze(4, 4)

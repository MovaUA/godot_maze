class_name Main
extends Node

var maze: Maze

func _ready() -> void:
	maze = MazeGenerator.generate_maze(Settings.MAZE_WIDTH, Settings.MAZE_HEIGHT)
	maze.print_maze("generated")

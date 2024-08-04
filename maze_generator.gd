@icon("res://maze.png")
class_name MazeGenerator
extends RefCounted

static func generate_maze(width: int, height: int) -> Maze:
	return Maze.new(width, height)

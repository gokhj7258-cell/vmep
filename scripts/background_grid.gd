extends Node2D

@export var grid_size: float = 64.0
@export var grid_extent: int = 60
@export var bg_color: Color = Color(0.08, 0.09, 0.11, 1.0)
@export var line_color: Color = Color(0.16, 0.18, 0.22, 0.6)
@export var axis_color: Color = Color(0.25, 0.28, 0.35, 0.8)

func _draw() -> void:
	var total_size: float = grid_extent * grid_size
	
	# 어두운 배경 사각형
	draw_rect(Rect2(-total_size, -total_size, total_size * 2, total_size * 2), bg_color)
	
	# 격자 라인
	for i in range(-grid_extent, grid_extent + 1):
		var pos: float = i * grid_size
		var color_to_use: Color = axis_color if i == 0 else line_color
		var width: float = 2.0 if i == 0 else 1.0
		
		# 세로선
		draw_line(Vector2(pos, -total_size), Vector2(pos, total_size), color_to_use, width)
		# 가로선
		draw_line(Vector2(-total_size, pos), Vector2(total_size, pos), color_to_use, width)

class_name ExpGem
extends Area2D

@export var exp_value: float = 10.0

var target: Node2D = null
var is_flying: bool = false
var current_speed: float = 120.0
var acceleration: float = 700.0
var max_speed: float = 700.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("gem")
	# 약간의 회전 또는 펄스 애니메이션
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "scale", Vector2(0.18, 0.18), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.14, 0.14), 0.5)

func _physics_process(delta: float) -> void:
	if not is_flying:
		return
		
	if not is_instance_valid(target):
		is_flying = false
		return
		
	current_speed = min(current_speed + acceleration * delta, max_speed)
	var dir: Vector2 = (target.global_position - global_position).normalized()
	global_position += dir * current_speed * delta
	
	if global_position.distance_to(target.global_position) <= 18.0:
		_collect()

func start_flying(player: Node2D) -> void:
	if is_flying:
		return
	target = player
	is_flying = true

func _collect() -> void:
	if is_instance_valid(target) and target.has_method("gain_exp"):
		target.gain_exp(exp_value)
	queue_free()

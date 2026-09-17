class_name EnemySpawner
extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.2
@export var spawn_distance_min: float = 650.0
@export var spawn_distance_max: float = 800.0
@export var enemies_per_spawn: int = 2

var spawn_timer: Timer

func _ready() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _on_spawn_timer_timeout() -> void:
	if enemy_scene == null:
		return
		
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
		
	var player: Node2D = players[0]
	
	for i in range(enemies_per_spawn):
		_spawn_enemy(player.global_position)

func _spawn_enemy(center_pos: Vector2) -> void:
	var angle: float = randf_range(0.0, TAU)
	var distance: float = randf_range(spawn_distance_min, spawn_distance_max)
	var spawn_pos: Vector2 = center_pos + Vector2(cos(angle), sin(angle)) * distance
	
	var enemy = enemy_scene.instantiate() as Node2D
	enemy.global_position = spawn_pos
	
	# 부모 노드나 적 컨테이너에 추가
	var container = get_node_or_null("../EnemyContainer")
	if container:
		container.call_deferred("add_child", enemy)
	else:
		get_parent().call_deferred("add_child", enemy)

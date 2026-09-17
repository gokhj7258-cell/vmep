class_name WeaponBase
extends Node2D

@export var weapon_name: String = "Base Weapon"
@export var damage: float = 15.0
@export var cooldown: float = 1.0:
	set(value):
		cooldown = max(0.1, value)
		if attack_timer:
			attack_timer.wait_time = cooldown
@export var attack_range: float = 500.0
@export var projectile_count: int = 1
@export var projectile_scene: PackedScene

var attack_timer: Timer

func _ready() -> void:
	attack_timer = Timer.new()
	attack_timer.wait_time = cooldown
	attack_timer.autostart = true
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func _on_attack_timer_timeout() -> void:
	attack()

func attack() -> void:
	pass

func get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest_enemy: Node2D = null
	var closest_distance: float = attack_range
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = enemy
			
	return closest_enemy

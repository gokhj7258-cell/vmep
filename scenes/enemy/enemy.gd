class_name Enemy
extends CharacterBody2D

signal enemy_died(enemy: Enemy)

@export var max_hp: float = 30.0
@export var speed: float = 85.0
@export var contact_damage: float = 10.0
@export var attack_cooldown: float = 0.6
@export var gem_scene: PackedScene = preload("res://scenes/items/exp_gem.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var current_hp: float = 30.0
var player: Node2D = null
var can_attack: bool = true
var is_dead: bool = false

func _ready() -> void:
	add_to_group("enemy")
	current_hp = max_hp
	_find_player()

func _find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(_delta: float) -> void:
	if is_dead:
		return
	
	if not is_instance_valid(player):
		_find_player()
		return
	
	var dir: Vector2 = (player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	
	# 플레이어 방향에 따른 스프라이트 반전
	if dir.x < 0.0:
		sprite.flip_h = true
	elif dir.x > 0.0:
		sprite.flip_h = false
	
	# 플레이어 접촉 데미지 처리
	_check_player_contact()

func _check_player_contact() -> void:
	if not can_attack or is_dead:
		return
		
	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider != null and collider.has_method("take_damage") and collider.is_in_group("player"):
			collider.take_damage(contact_damage)
			_start_attack_cooldown()
			break

func _start_attack_cooldown() -> void:
	can_attack = false
	get_tree().create_timer(attack_cooldown).timeout.connect(func():
		can_attack = true
	)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	
	current_hp -= amount
	_play_hit_flash()
	
	if current_hp <= 0.0:
		_die()

func _play_hit_flash() -> void:
	var tween: Tween = create_tween()
	var original_modulate: Color = Color(1.0, 0.35, 0.35, 1.0) # 기본 붉은색
	sprite.modulate = Color(2.0, 2.0, 2.0, 1.0) # 피격 시 밝은 백색 플래시
	tween.tween_property(sprite, "modulate", original_modulate, 0.1)

func _die() -> void:
	is_dead = true
	remove_from_group("enemy") # 타겟팅 방지
	enemy_died.emit(self)
	
	_drop_gem()
	
	# 충돌 비활성화
	collision_shape.set_deferred("disabled", true)
	
	# 사망 축소 연출 후 제거
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)

func _drop_gem() -> void:
	if gem_scene == null:
		return
	var gem: Node2D = gem_scene.instantiate() as Node2D
	gem.global_position = global_position
	
	var container = get_node_or_null("/root/Main/GemContainer")
	if container:
		container.call_deferred("add_child", gem)
	elif get_tree() and get_tree().current_scene:
		get_tree().current_scene.call_deferred("add_child", gem)

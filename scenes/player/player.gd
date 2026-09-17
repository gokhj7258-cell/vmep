class_name Player
extends CharacterBody2D

signal health_changed(current_hp: float, max_hp: float)
signal exp_changed(current_exp: float, max_exp: float, level: int)
signal leveled_up(new_level: int)
signal player_died

@export var move_speed: float = 220.0
@export var max_hp: float = 100.0
@export var pickup_radius: float = 110.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea
@onready var pickup_collision: CollisionShape2D = $PickupArea/CollisionShape2D
@onready var weapons_holder: Node2D = $Weapons

var current_hp: float = 100.0
var current_level: int = 1
var current_exp: float = 0.0
var max_exp: float = 30.0

var is_invulnerable: bool = false
var invulnerability_time: float = 0.5

func _ready() -> void:
	add_to_group("player")
	_ensure_input_mappings()
	_ensure_animations()
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
	exp_changed.emit(current_exp, max_exp, current_level)
	
	if anim_player and anim_player.has_animation("idle"):
		anim_player.play("idle")
	sprite.flip_h = true
	
	if pickup_area:
		pickup_area.area_entered.connect(_on_pickup_area_entered)
		_update_pickup_shape()

func _physics_process(_delta: float) -> void:
	_handle_movement()

func _handle_movement() -> void:
	var input_direction: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)
	
	velocity = input_direction * move_speed
	move_and_slide()
	
	# 애니메이션 및 좌우 반전 제어
	if velocity.length() > 5.0:
		if anim_player:
			anim_player.speed_scale = move_speed / 220.0
			if anim_player.current_animation != "walk":
				anim_player.play("walk")
		# 원본 스프라이트가 왼쪽을 향하고 있으므로, 우측 이동 시 flip_h = true, 좌측 이동 시 flip_h = false
		if velocity.x < 0.0:
			sprite.flip_h = false
		elif velocity.x > 0.0:
			sprite.flip_h = true
	else:
		if anim_player and anim_player.current_animation != "idle":
			anim_player.play("idle")

func _on_pickup_area_entered(area: Area2D) -> void:
	if area.has_method("start_flying"):
		area.start_flying(self)

func gain_exp(amount: float) -> void:
	current_exp += amount
	while current_exp >= max_exp:
		current_exp -= max_exp
		current_level += 1
		max_exp = int(max_exp * 1.35 + 10.0)
		leveled_up.emit(current_level)
	
	exp_changed.emit(current_exp, max_exp, current_level)

func apply_upgrade(upgrade_id: String) -> void:
	match upgrade_id:
		"wand_damage":
			var wand = weapons_holder.get_node_or_null("MagicWand")
			if wand:
				wand.damage = wand.damage * 1.3 + 3.0
		"wand_cooldown":
			var wand = weapons_holder.get_node_or_null("MagicWand")
			if wand:
				wand.cooldown = max(0.2, wand.cooldown * 0.85)
		"wand_projectile":
			var wand = weapons_holder.get_node_or_null("MagicWand")
			if wand:
				wand.projectile_count += 1
		"player_speed":
			move_speed += 35.0
		"magnet_range":
			pickup_radius += 45.0
			_update_pickup_shape()
		"max_hp":
			max_hp += 25.0
			current_hp = min(max_hp, current_hp + 35.0)
			health_changed.emit(current_hp, max_hp)

func _update_pickup_shape() -> void:
	if pickup_collision and pickup_collision.shape is CircleShape2D:
		(pickup_collision.shape as CircleShape2D).radius = pickup_radius

func take_damage(amount: float) -> void:
	if is_invulnerable or current_hp <= 0.0:
		return
	
	current_hp = max(0.0, current_hp - amount)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0.0:
		_die()
	else:
		_trigger_invulnerability()

func _trigger_invulnerability() -> void:
	is_invulnerable = true
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.4, 0.1)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.set_loops(int(invulnerability_time / 0.2))
	
	get_tree().create_timer(invulnerability_time).timeout.connect(func():
		is_invulnerable = false
		sprite.modulate.a = 1.0
	)

func _die() -> void:
	player_died.emit()
	set_physics_process(false)

func _ensure_input_mappings() -> void:
	var actions = {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN]
	}
	for action_name in actions.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			for key in actions[action_name]:
				var ev = InputEventKey.new()
				ev.keycode = key
				InputMap.action_add_event(action_name, ev)

func _ensure_animations() -> void:
	if not anim_player:
		return
	var lib: AnimationLibrary
	if anim_player.has_animation_library(""):
		lib = anim_player.get_animation_library("")
	else:
		lib = AnimationLibrary.new()
		anim_player.add_animation_library("", lib)
	
	if not lib.has_animation("idle"):
		var anim_idle = Animation.new()
		anim_idle.length = 0.1
		anim_idle.loop_mode = Animation.LOOP_LINEAR
		var t0 = anim_idle.add_track(Animation.TYPE_VALUE)
		anim_idle.track_set_path(t0, "Sprite2D:frame")
		anim_idle.track_insert_key(t0, 0.0, 0)
		lib.add_animation("idle", anim_idle)
	
	if not lib.has_animation("walk"):
		var anim_walk = Animation.new()
		anim_walk.length = 0.6
		anim_walk.loop_mode = Animation.LOOP_LINEAR
		anim_walk.step = 0.1
		var t1 = anim_walk.add_track(Animation.TYPE_VALUE)
		anim_walk.track_set_path(t1, "Sprite2D:frame")
		for i in range(6):
			anim_walk.track_insert_key(t1, i * 0.1, i)
		lib.add_animation("walk", anim_walk)

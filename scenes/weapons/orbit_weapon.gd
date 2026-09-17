class_name OrbitWeapon
extends WeaponBase

@export var orb_scene: PackedScene = preload("res://scenes/weapons/orbit_orb.tscn")
@export var orbit_radius: float = 75.0
@export var rotation_speed: float = 3.6
@export var orb_count: int = 1

var current_angle: float = 0.0
var orbs: Array[OrbitOrb] = []
var weapon_level: int = 1

func _ready() -> void:
	weapon_name = "Orbit Shield"
	damage = 14.0
	# 공전형 무기는 타이머 발사가 아닌 상시 회전이므로 타이머 정지
	if attack_timer:
		attack_timer.stop()
	update_orbs()

func _physics_process(delta: float) -> void:
	if orbs.is_empty():
		return
		
	current_angle += rotation_speed * delta
	if current_angle >= TAU:
		current_angle -= TAU
		
	var step: float = TAU / float(orbs.size())
	for i in range(orbs.size()):
		if is_instance_valid(orbs[i]):
			var angle: float = current_angle + (float(i) * step)
			orbs[i].position = Vector2(cos(angle), sin(angle)) * orbit_radius

func update_orbs() -> void:
	# 기존 오브 제거
	for orb in orbs:
		if is_instance_valid(orb):
			orb.queue_free()
	orbs.clear()
	
	if orb_scene == null:
		return
		
	# 신규 오브 생성 및 배치
	for i in range(orb_count):
		var orb = orb_scene.instantiate() as OrbitOrb
		orb.damage = damage
		add_child(orb)
		orbs.append(orb)

func upgrade_level() -> void:
	weapon_level += 1
	match weapon_level:
		2:
			orb_count = 2
			damage += 4.0
			rotation_speed += 0.4
		3:
			orb_count = 3
			damage += 5.0
			orbit_radius += 10.0
		4:
			orb_count = 4
			damage += 6.0
			rotation_speed += 0.6
		_:
			damage += 5.0
			rotation_speed += 0.2
	update_orbs()

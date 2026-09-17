class_name OrbitOrb
extends Area2D

@export var damage: float = 12.0
@export var hit_cooldown: float = 0.35

var last_hit_times: Dictionary = {}

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# 부드러운 펄스 회전 연출
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "rotation", TAU, 1.0).from(0.0)

func _physics_process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# 영역 안에 머물고 있는 적들에게 주기적 타격 적용
	for body in get_overlapping_bodies():
		_try_damage(body, current_time)
	for area in get_overlapping_areas():
		_try_damage(area, current_time)

func _on_body_entered(body: Node2D) -> void:
	_try_damage(body, Time.get_ticks_msec() / 1000.0)

func _on_area_entered(area: Area2D) -> void:
	_try_damage(area, Time.get_ticks_msec() / 1000.0)

func _try_damage(target: Node, current_time: float) -> void:
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return
		
	var target_id = target.get_instance_id()
	if last_hit_times.has(target_id):
		if current_time - last_hit_times[target_id] < hit_cooldown:
			return
			
	last_hit_times[target_id] = current_time
	target.take_damage(damage)
	
	# 타격 시 밝은 스파크 플래시 효과
	var flash_tween = create_tween()
	flash_tween.tween_property(sprite, "scale", Vector2(0.24, 0.24), 0.06)
	flash_tween.tween_property(sprite, "scale", Vector2(0.18, 0.18), 0.08)

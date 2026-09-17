class_name WhipSlash
extends Area2D

@export var damage: float = 32.0
@export var duration: float = 0.18

var hit_targets: Array[Node] = []

@onready var visual_rect: ColorRect = $VisualRect
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# 즉시 현재 영역에 겹쳐있는 모든 적 타격
	call_deferred("_check_initial_overlaps")
	
	# 참격 비주얼 애니메이션 (순간 확대 후 빠른 페이드아웃)
	scale = Vector2(0.3, 1.2)
	modulate = Color(2.0, 2.0, 1.5, 1.0) # 강한 섬광 효과
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), duration * 0.4)
	tween.tween_property(self, "modulate:a", 0.0, duration).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

func _check_initial_overlaps() -> void:
	for body in get_overlapping_bodies():
		_handle_hit(body)
	for area in get_overlapping_areas():
		_handle_hit(area)

func _on_body_entered(body: Node2D) -> void:
	_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _handle_hit(target: Node) -> void:
	if not is_instance_valid(target) or target in hit_targets:
		return
		
	if target.has_method("take_damage"):
		hit_targets.append(target)
		target.take_damage(damage)

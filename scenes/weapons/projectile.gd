class_name Projectile
extends Area2D

@export var speed: float = 480.0
@export var damage: float = 15.0
@export var pierce: int = 1
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT
var hit_targets: Array[Node] = []

func _ready() -> void:
	# 수명 타이머 연결
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(func():
		if is_inside_tree():
			queue_free()
	)
	
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	_handle_hit(body)

func _on_area_entered(area: Area2D) -> void:
	_handle_hit(area)

func _handle_hit(target: Node) -> void:
	if target in hit_targets:
		return
	
	if target.has_method("take_damage"):
		hit_targets.append(target)
		target.take_damage(damage)
		pierce -= 1
		if pierce <= 0:
			queue_free()

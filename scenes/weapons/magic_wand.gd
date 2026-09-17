class_name MagicWand
extends WeaponBase

func attack() -> void:
	if projectile_scene == null:
		return
	
	var target: Node2D = get_closest_enemy()
	if target == null:
		return
	
	var base_direction: Vector2 = (target.global_position - global_position).normalized()
	
	for i in range(projectile_count):
		if i == 0:
			_spawn_projectile(base_direction)
		else:
			# 다중 투사체 발사 시 약간의 시간차 또는 각도 분산
			var spread_angle: float = deg_to_rad((i - float(projectile_count - 1) / 2.0) * 15.0)
			var spread_dir: Vector2 = base_direction.rotated(spread_angle)
			_spawn_projectile(spread_dir)

func _spawn_projectile(dir: Vector2) -> void:
	var proj: Projectile = projectile_scene.instantiate() as Projectile
	proj.global_position = global_position
	proj.direction = dir
	proj.damage = damage
	
	var current_scene: Node = get_tree().current_scene
	if current_scene:
		current_scene.call_deferred("add_child", proj)
	else:
		get_parent().call_deferred("add_child", proj)

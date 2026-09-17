extends Node2D

@onready var player: Player = $Player
@onready var hp_bar: ProgressBar = $UI/HUD/TopBar/HPContainer/HPBar
@onready var hp_label: Label = $UI/HUD/TopBar/HPContainer/HPLabel
@onready var exp_bar: ProgressBar = $UI/HUD/TopBar/EXPContainer/EXPBar
@onready var exp_label: Label = $UI/HUD/TopBar/EXPContainer/EXPLabel
@onready var level_label: Label = $UI/HUD/TopBar/LevelLabel
@onready var level_up_modal: LevelUpModal = $UI/LevelUpModal

func _ready() -> void:
	if player:
		player.health_changed.connect(_on_player_health_changed)
		player.exp_changed.connect(_on_player_exp_changed)
		player.leveled_up.connect(_on_player_leveled_up)
		
		# 초기값 반영
		_on_player_health_changed(player.current_hp, player.max_hp)
		_on_player_exp_changed(player.current_exp, player.max_exp, player.current_level)
		
	if level_up_modal:
		level_up_modal.upgrade_selected.connect(_on_upgrade_selected)

func _on_player_health_changed(current: float, maximum: float) -> void:
	if hp_bar:
		hp_bar.max_value = maximum
		hp_bar.value = current
	if hp_label:
		hp_label.text = "HP: %d / %d" % [int(current), int(maximum)]

func _on_player_exp_changed(current: float, maximum: float, level: int) -> void:
	if exp_bar:
		exp_bar.max_value = maximum
		exp_bar.value = current
	if exp_label:
		exp_label.text = "EXP: %d / %d" % [int(current), int(maximum)]
	if level_label:
		level_label.text = "Lv. %d" % level

func _on_player_leveled_up(new_level: int) -> void:
	if level_up_modal:
		level_up_modal.open(new_level)

func _on_upgrade_selected(upgrade_id: String) -> void:
	if player:
		player.apply_upgrade(upgrade_id)

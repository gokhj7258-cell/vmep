class_name LevelUpModal
extends Control

signal upgrade_selected(upgrade_id: String)

@export var card_scene: PackedScene = preload("res://scenes/ui/level_up_card.tscn")

@onready var card_container: HBoxContainer = $CenterContainer/VBoxContainer/CardContainer
@onready var level_label: Label = $CenterContainer/VBoxContainer/LevelLabel

const UPGRADE_POOL = [
	{
		"id": "wand_damage",
		"name": "지팡이 위력 증폭",
		"type": "WEAPON",
		"description": "마법 탄환의 피해량이 30% 증가합니다."
	},
	{
		"id": "wand_cooldown",
		"name": "신속의 영창",
		"type": "WEAPON",
		"description": "탄환 발사 간격이 15% 단축됩니다."
	},
	{
		"id": "wand_projectile",
		"name": "다중 마법 탄환",
		"type": "WEAPON",
		"description": "한 번에 발사되는 마법 탄환 수가 1개 증가합니다."
	},
	{
		"id": "player_speed",
		"name": "질주의 부적",
		"type": "PASSIVE",
		"description": "플레이어의 이동 속도가 증가합니다."
	},
	{
		"id": "magnet_range",
		"name": "자석 인력 강화",
		"type": "PASSIVE",
		"description": "경험치 보석을 끌어당기는 수집 반경이 넓어집니다."
	},
	{
		"id": "max_hp",
		"name": "거인의 심장",
		"type": "PASSIVE",
		"description": "최대 체력이 25 증가하고 체력을 즉시 35 회복합니다."
	}
]

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func open(level: int) -> void:
	level_label.text = "★ LEVEL UP! (Lv.%d) ★" % level
	_clear_cards()
	
	# 무작위 3개 선택 (셔플)
	var pool_copy = UPGRADE_POOL.duplicate()
	pool_copy.shuffle()
	
	var select_count = min(3, pool_copy.size())
	for i in range(select_count):
		var item_data = pool_copy[i]
		var card = card_scene.instantiate() as LevelUpCard
		card_container.add_child(card)
		card.setup(item_data)
		card.card_selected.connect(_on_card_selected)
		
	visible = true
	get_tree().paused = true

func _on_card_selected(id: String) -> void:
	visible = false
	get_tree().paused = false
	upgrade_selected.emit(id)
	_clear_cards()

func _clear_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()

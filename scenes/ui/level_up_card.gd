class_name LevelUpCard
extends Button

signal card_selected(upgrade_id: String)

var upgrade_id: String = ""

@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var desc_label: Label = $MarginContainer/VBoxContainer/DescLabel
@onready var tag_label: Label = $MarginContainer/VBoxContainer/TagLabel

func setup(data: Dictionary) -> void:
	upgrade_id = data.get("id", "")
	if not is_node_ready():
		await ready
	
	title_label.text = data.get("name", "")
	desc_label.text = data.get("description", "")
	tag_label.text = "[" + data.get("type", "UPGRADE") + "]"
	
	if data.get("type", "") == "WEAPON":
		tag_label.modulate = Color(0.4, 0.8, 1.0)
	elif data.get("type", "") == "PASSIVE":
		tag_label.modulate = Color(0.5, 1.0, 0.5)
	else:
		tag_label.modulate = Color(1.0, 0.85, 0.3)

func _pressed() -> void:
	card_selected.emit(upgrade_id)

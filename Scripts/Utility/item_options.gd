extends ColorRect

@onready var lblName = $lbl_name
@onready var lblDescription = $lbl_desc 
@onready var lblLevel = $lbl_level
@onready var itemIcon = $ColorRect/ItemIcon


var mouse_over = false
var item = null
@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("player")

signal selected_upgrade(upgrade)

func _ready():
	connect("selected_upgrade", Callable(player, "upgrade_character"))
	lblName.text = UpgradeDb.UPGRADES[item]["displayname"]
	lblDescription.text = UpgradeDb.UPGRADES[item]["details"]
	lblLevel.text = UpgradeDb.UPGRADES[item]["level"]
	itemIcon.texture = load(UpgradeDb.UPGRADES[item]["icon"])
	
func _input(event: InputEvent) -> void:
	if(event.is_action("Click") && mouse_over):
		emit_signal("selected_upgrade", item)

func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

extends TextureRect

var upgrade = null
@onready var item_icon = $ItemIcon

# Called when the node enters the scene tree for the first time.
func _ready():
	if upgrade != null:
		item_icon.texture = load(UpgradeDb.UPGRADES[upgrade]["icon"])

extends Node


const ICON_PATH = "res://Assets/Sprites/Player/Skills/"
const WEAPON_PATH = "res://Assets/Sprites/Player/Attacks/"
const UPGRADES = {
	"letter_opener1": {
		"icon": WEAPON_PATH + "ouvre_lettre.png",
		"displayname": "Ouvre Lettre",
		"details": "A spear of ice is thrown at a random enemy",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"letter_opener2": {
		"icon": WEAPON_PATH + "ouvre_lettre.png",
		"displayname": "Ouvre Lettre",
		"details": "An additional Ouvre Lettre is thrown",
		"level": "Level: 2",
		"prerequisite": ["letter_opener1"],
		"type": "weapon"
	},
	"letter_opener3": {
		"icon": WEAPON_PATH + "ouvre_lettre.png",
		"displayname": "Ouvre Lettre",
		"details": "Ouvre Lettres now pass through another enemy and do + 3 damage",
		"level": "Level: 3",
		"prerequisite": ["letter_opener2"],
		"type": "weapon"
	},
	"letter_opener4": {
		"icon": WEAPON_PATH + "ouvre_lettre.png",
		"displayname": "Ouvre Lettre",
		"details": "An additional 2 Ouvre Lettres are thrown",
		"level": "Level: 4",
		"prerequisite": ["letter_opener3"],
		"type": "weapon"
	},
	"staby1": {
		"icon": WEAPON_PATH + "STABY.png",
		"displayname": "STABY",
		"details": "A magical staby will follow you attacking enemies in a straight line",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"staby2": {
		"icon": WEAPON_PATH + "STABY.png",
		"displayname": "STABY",
		"details": "The staby will now attack an additional enemy per attack",
		"level": "Level: 2",
		"prerequisite": ["staby1"],
		"type": "weapon"
	},
	"staby3": {
		"icon": WEAPON_PATH + "STABY.png",
		"displayname": "STABY",
		"details": "The staby will attack another additional enemy per attack",
		"level": "Level: 3",
		"prerequisite": ["staby2"],
		"type": "weapon"
	},
	"staby4": {
		"icon": WEAPON_PATH + "STABY.png",
		"displayname": "STABY",
		"details": "The staby now does + 5 damage per attack and causes 20% additional knockback",
		"level": "Level: 4",
		"prerequisite": ["staby3"],
		"type": "weapon"
	},
	"letter1": {
		"icon": WEAPON_PATH + "letter.webp",
		"displayname": "Lettre",
		"details": "A tornado is created and random heads somewhere in the players direction",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "weapon"
	},
	"letter2": {
		"icon": WEAPON_PATH + "letter.webp",
		"displayname": "Lettre",
		"details": "An additional Lettre is created",
		"level": "Level: 2",
		"prerequisite": ["letter1"],
		"type": "weapon"
	},
	"letter3": {
		"icon": WEAPON_PATH + "letter.webp",
		"displayname": "Lettre",
		"details": "The Lettre cooldown is reduced by 0.5 seconds",
		"level": "Level: 3",
		"prerequisite": ["letter2"],
		"type": "weapon"
	},
	"letter4": {
		"icon": WEAPON_PATH + "letter.webp",
		"displayname": "Lettre",
		"details": "An additional tornado is created and the knockback is increased by 25%",
		"level": "Level: 4",
		"prerequisite": ["letter3"],
		"type": "weapon"
	},
	"armor1": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By 1 point",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"armor2": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 2",
		"prerequisite": ["armor1"],
		"type": "upgrade"
	},
	"armor3": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 3",
		"prerequisite": ["armor2"],
		"type": "upgrade"
	},
	"armor4": {
		"icon": ICON_PATH + "helmet_1.png",
		"displayname": "Armor",
		"details": "Reduces Damage By an additional 1 point",
		"level": "Level: 4",
		"prerequisite": ["armor3"],
		"type": "upgrade"
	},
	"speed1": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by 50% of base speed",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"speed2": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 2",
		"prerequisite": ["speed1"],
		"type": "upgrade"
	},
	"speed3": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased by an additional 50% of base speed",
		"level": "Level: 3",
		"prerequisite": ["speed2"],
		"type": "upgrade"
	},
	"speed4": {
		"icon": ICON_PATH + "boots_4_green.png",
		"displayname": "Speed",
		"details": "Movement Speed Increased an additional 50% of base speed",
		"level": "Level: 4",
		"prerequisite": ["speed3"],
		"type": "upgrade"
	},
	"tome1": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"tome2": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 2",
		"prerequisite": ["tome1"],
		"type": "upgrade"
	},
	"tome3": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 3",
		"prerequisite": ["tome2"],
		"type": "upgrade"
	},
	"tome4": {
		"icon": ICON_PATH + "thick_new.png",
		"displayname": "Tome",
		"details": "Increases the size of spells an additional 10% of their base size",
		"level": "Level: 4",
		"prerequisite": ["tome3"],
		"type": "upgrade"
	},
	"scroll1": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"scroll2": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 2",
		"prerequisite": ["scroll1"],
		"type": "upgrade"
	},
	"scroll3": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 3",
		"prerequisite": ["scroll2"],
		"type": "upgrade"
	},
	"scroll4": {
		"icon": ICON_PATH + "scroll_old.png",
		"displayname": "Scroll",
		"details": "Decreases of the cooldown of spells by an additional 5% of their base time",
		"level": "Level: 4",
		"prerequisite": ["scroll3"],
		"type": "upgrade"
	},
	"ring1": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn 1 more additional attack",
		"level": "Level: 1",
		"prerequisite": [],
		"type": "upgrade"
	},
	"ring2": {
		"icon": ICON_PATH + "urand_mage.png",
		"displayname": "Ring",
		"details": "Your spells now spawn an additional attack",
		"level": "Level: 2",
		"prerequisite": ["ring1"],
		"type": "upgrade"
	},
	"food": {
		"icon": ICON_PATH + "chunk.png",
		"displayname": "Food",
		"details": "Heals you for 20 health",
		"level": "N/A",
		"prerequisite": [],
		"type": "item"
	}
}

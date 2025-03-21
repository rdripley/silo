class_name weapon_component extends Node

var weapons_dict = {
# pistol attributes
	"Pistol": { 
	"shoot_speed": 3.0,
	"reload_speed": 33.0,
	"bullet_speed": 600, 
	"damage": 15,
	"num_bullets": 17,
	"weapon_texture": "res://assets/weapons/energy_pistol.png" },
# shotgun attributes
	"Shotgun": { 
	"shoot_speed": 1.5,
	"reload_speed": 3.0,
	"bullet_speed": 600, 
	"damage": 45,
	"num_bullets": 12,
	"weapon_texture": "res://assets/weapons/energy_shotgun.png" },
# rifle attributes
	"Rifle": { 
	"shoot_speed": 2.0,
	"reload_speed": 2.0,
	"bullet_speed": 600, 
	"damage": 60,
	"num_bullets": 8,
	"weapon_texture": "res://assets/weapons/energy_rifle.png" },
# rocket launcher attributes
	"Rocket_Launcher": { 
	"shoot_speed": .5,
	"reload_speed": 4.0,
	"bullet_speed": 500,
	"num_bullets": 4, 
	"damage": 100 }
}

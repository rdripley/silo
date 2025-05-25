class_name hurtBox extends Node

signal damage_taken
signal knockback

var gun = weapon_component.new()

var bullet_damage = gun.weapons_dict.Pistol.damage
var player_damage = 10

@export var area2D: Area2D

func _ready() -> void:
	area2D.area_entered.connect(collision)

func collision(collider) -> void:
	if collider.name == "EnemyHitbox":
		knockback.emit(collider)
		damage_taken.emit(player_damage)
	if collider.is_in_group("Bullets"):
		knockback.emit(collider)
		damage_taken.emit(bullet_damage)

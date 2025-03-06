class_name hurtBox extends Node

signal damage_taken
signal knockback

var gun = weapon_component.new()

var bullet_damage = gun.weapons_dict.Pistol.damage

@export var area2D: Area2D

func _ready() -> void:
	area2D.area_entered.connect(collision)

func collision(collider) -> void:
	if collider.name == "EnemyHitbox": return
	knockback.emit(collider)
	damage_taken.emit(bullet_damage)

extends Node2D

const BULLET = preload("res://scenes/components/bullet_component.tscn")

@onready var gun_component = weapon_component.new()
@onready var marker_2d = %GunMarker
@onready var shoot_speed_timer = %GunShootSpeedTimer
@onready var gun: Node = %Gun
@onready var gun_sprite: Sprite2D = %GunSprite

@onready var shoot_speed = gun_component.weapons_dict.Pistol.shoot_speed
var canShoot = true
var bulletDirection = Vector2(1,0)

func _ready():
	shoot_speed_timer.wait_time = 1.0 / shoot_speed
	
func _shoot():
	if canShoot:
		canShoot = false
		shoot_speed_timer.start()
		
		var bulletNode = BULLET.instantiate()
		
		bulletNode.set_direction(bulletDirection)
		get_tree().root.add_child(bulletNode)
		bulletNode.global_position = marker_2d.global_position
		
func _on_shoot_speed_timer_timeout() -> void:
	canShoot = true
	
func _setup_direction(direction, is_left):
	bulletDirection = direction
	
	gun_sprite.flip_v = is_left
	gun.rotation = direction.angle()
	
func _switch_weapon():
	var new_texture = load(gun_component.weapons_dict.Rifle.weapon_texture)
	gun_sprite.texture = new_texture

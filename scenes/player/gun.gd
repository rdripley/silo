extends Node2D

const BULLET = preload("res://scenes/components/bullet_component.tscn")

@onready var gun_component = weapon_component.new()
@onready var marker_2d = %GunMarker
@onready var shoot_speed_timer = %GunShootSpeedTimer
@onready var gun: Node = %Gun
@onready var gun_sprite: Sprite2D = %GunSprite
@onready var reload_bar: TextureProgressBar = %ReloadBar

@onready var shoot_speed: float = gun_component.weapons_dict.Pistol.shoot_speed
@onready var bullet_count: int = gun_component.weapons_dict.Pistol.num_bullets
@onready var reload_speed: float = gun_component.weapons_dict.Pistol.reload_speed
var canShoot: bool = true
var bulletDirection = Vector2(1,0)
var current_bullet_count: int

func _ready():
	shoot_speed_timer.wait_time = 1.0 / shoot_speed
	current_bullet_count = 6
	reload_bar.visible = false
	
func _reload():
	canShoot = false
	reload_bar.visible = true

	for i in range(reload_bar.value):
		reload_bar.value -= reload_speed
		await get_tree().create_timer(.5).timeout
		if reload_bar.value <= 0:
			break;
	current_bullet_count = 6
	reload_bar.value = 100
	reload_bar.visible = false
	canShoot = true
	
func _shoot():
	if canShoot && current_bullet_count > 0:
		canShoot = false
		shoot_speed_timer.start()
		current_bullet_count = current_bullet_count - 1

		if current_bullet_count == 0:
			_reload()

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

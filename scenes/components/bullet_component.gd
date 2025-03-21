class_name bullet_component extends Area2D

var gun = weapon_component.new()

var bullet_speed = gun.weapons_dict.Pistol.bullet_speed

var direction = Vector2(1,0)

func _ready():
	await get_tree().create_timer(10).timeout
	queue_free()

func set_direction(bulletDirection):
		direction = bulletDirection
		rotation_degrees = rad_to_deg(global_position.angle_to_point(direction))

func _physics_process(delta):
	global_position += direction * bullet_speed * delta
	
func _on_area_entered(area: Area2D) -> void:
	if area.name == "EnemyHitbox":
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	var body_check = body.name.to_lower()
	if body_check.contains("map"):
		queue_free()

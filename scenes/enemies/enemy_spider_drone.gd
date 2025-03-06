extends CharacterBody2D

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var knockback_power: int = 300

var died = false
const SPEED = 400.0
const JUMP_VELOCITY = -400.0

func _animations(a):
	sprite_2d.animation = a

func knockback(enemyVelocity: Vector2):
	var knockback_direction = (velocity - enemyVelocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()
	await get_tree().create_timer(.5).timeout
	velocity = Vector2(0,0)
	move_and_slide()

func _physics_process(delta: float) -> void:

	#Animations
	if (velocity.x > 1 || velocity.x < -1):
		_animations("running")
	else:
		_animations("default")
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		_animations("jumping")
		
	move_and_slide()

func is_dead() -> void:
	died = true
	print_debug(died)
	if died == true:
		queue_free()


func _on_hurt_box_knockback(area: Area2D) -> void:
	var damage_direction = area.global_position - sprite_2d.global_position
	#print_debug(damage_direction)
	knockback(damage_direction)

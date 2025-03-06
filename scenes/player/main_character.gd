extends CharacterBody2D
class_name Player

# Imported Objects
@onready var sprite_2d: AnimatedSprite2D = %PlayerSprite
@onready var fuel_bar: TextureProgressBar = %JetPackFuelBar
@onready var jetpack_animation_left: GPUParticles2D = %"Left Jetpack Nozzle"
@onready var jetpack_animation_right: GPUParticles2D = %"Right Jetpack Nozzle"
@onready var gun = %Gun
@onready var player_health_bar = %PlayerHealthBar
@onready var hit_flash_anim_player = %HitFlash
@onready var hurt_timer = %HurtTimer

# Player movement
@export var speed = 400.0
@export var jump_velocity = -400.0
@export var knockback_power: int = 500
var default_direction = Vector2.RIGHT
var is_left = false
var is_hurt: bool = false

# player health
@export var max_health = 30
@onready var current_health: int = max_health

# Jetpack attributes
const jetpack_velocity = -500.0
var fuel = 100.0
var maximum_fuel = fuel
var minimum_fuel = 0
var fuel_empty = false

# Set thumbstick direction
var thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

# animations
func _animations(a):
	sprite_2d.animation = a

# jetpack functionality
func _jetPack():
	#Toggle Visibility of Fuel Bar
	if maximum_fuel == fuel:
		fuel_bar.visible = false;
	else: 
		fuel_bar.visible = true;
	
	# In Air JetPack Logic
	if fuel_empty == false:
		if (Input.is_action_pressed("jump") || Input.is_action_just_pressed("jump")) and not is_on_floor() and fuel_bar.value != 0:
			jetpack_animation_left.emitting = true
			jetpack_animation_right.emitting = true
			velocity.y = jetpack_velocity
			fuel = fuel - 1
			if (fuel < 0):
				fuel = minimum_fuel
			fuel_bar.value = fuel

		if fuel_bar.value == 0:
			fuel_empty = true
			
	#Refuel JetPack logic
	if (fuel > 1 and fuel < 50) and not is_on_floor():
		fuel = fuel + .02
		if (fuel > maximum_fuel):
			fuel = maximum_fuel
		fuel_bar.value = fuel
	else:
		fuel_empty = false
	
	if is_on_floor() and fuel < maximum_fuel:
		fuel = fuel + 1
		if (fuel > maximum_fuel):
			fuel = maximum_fuel
		fuel_bar.value = fuel
		fuel_empty = false

# handle gun direction and actions
func _handle_gun(gun_direction, gun_facing_left):

	# Handle Gun Inputs
	if Input.is_action_pressed("attack"):
		gun._shoot()
	
	gun._setup_direction(gun_direction, gun_facing_left)

# handle player/enemy collision
func _handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()


func knockback(enemyVelocity: Vector2):
	var knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()
	
# handle all player movement
func _player_movement():
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 50)
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# get thumbstick direction
	thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
	
	# Change Character & Weapon Direction
	if Input.is_action_pressed("left"):
		default_direction = Vector2.LEFT
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
			is_left = true
			sprite_2d.flip_h = is_left
		elif thumb_stick_direction != Vector2(0,0):
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
			is_left = true
			sprite_2d.flip_h = is_left

		_handle_gun(thumb_stick_direction, is_left)
		
	elif sprite_2d.animation == "default":
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
		else:
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		
		if default_direction == Vector2(1,0):
			is_left = false
		else:
			is_left = true
		_handle_gun(thumb_stick_direction, is_left)
		
	elif Input.is_action_pressed("right"):
		default_direction = Vector2.RIGHT
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
			is_left = false
			sprite_2d.flip_h = is_left
		elif thumb_stick_direction != Vector2(0,0):
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
			is_left = false
			sprite_2d.flip_h = is_left
			
		_handle_gun(thumb_stick_direction, is_left)

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
		
	# player movement call
	_player_movement()
	# jetpack movement call
	_jetPack()
	# handle collisions
	_handle_collision()
	
	move_and_slide()

func _ready() -> void:
	player_health_bar.value = current_health

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_hurt: return
	if area.name == "EnemyHitbox":
		current_health -= 1
		if current_health < 0:
			current_health = max_health
		player_health_bar.update()
		is_hurt = true
		knockback(area.get_parent().velocity)
		hit_flash_anim_player.play("hit_flash")
		hurt_timer.start()
		await hurt_timer.timeout
		hit_flash_anim_player.stop()
		sprite_2d.modulate = Color.WHITE
		is_hurt = false

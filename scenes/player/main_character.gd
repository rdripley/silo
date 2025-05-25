extends CharacterBody2D
class_name Player

signal player_respawned()

# Imported Objects
@onready var player_sprite: AnimatedSprite2D = %PlayerSprite
@onready var fuel_bar: TextureProgressBar = %JetPackFuelBar
@onready var jetpack_animation_left: GPUParticles2D = %"Left Jetpack Nozzle"
@onready var jetpack_animation_right: GPUParticles2D = %"Right Jetpack Nozzle"
@onready var gun: Node2D = %Gun
@onready var player_health_bar: TextureProgressBar = %PlayerHealthBar
@onready var hit_flash_anim_player: AnimationPlayer = %HitFlash
@onready var jetpack_reful_anim_player: AnimationPlayer = %JetpackEmptyAnim
@onready var hurt_timer: Timer = %HurtTimer
@onready var refuel_timer: Timer = %JetpackRefuelTimer
@onready var respawn_timer: Timer = %PlayerRespawnTimer
@onready var knockback_timer: Timer = %KnockbackTimer
@onready var player_class_instance = Player.new()
@onready var player_hurtbox: Area2D = %PlayerHurtbox


# Player
@export var speed: float = 400.0
@export var jump_velocity: float = -400.0
@export var knockback_power: float = 700.0
var default_direction = Vector2.RIGHT
var is_left: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var player_direction: float

# Jetpack attributes
const jetpack_velocity: float = -650.0
var fuel: float = 100.0
var maximum_fuel: float = fuel
var minimum_fuel: float = 0
var fuel_empty: bool = false
var can_refuel: bool = true
var wait_to_refuel: bool = false
var is_knockedback: bool = false

# Set thumbstick direction
var thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

# animations
func _animations(a):
	player_sprite.animation = a

# jetpack functionality
func _jetPack(jetpack_direction):
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

			if jetpack_direction:
				velocity.x = (jetpack_direction * -1) * jetpack_velocity
			else:
				velocity.x = move_toward(velocity.x, 0, 50)
			
			fuel = fuel - 1
			if (fuel < 0):
				fuel = minimum_fuel
			fuel_bar.value = fuel

		if fuel_bar.value == 0:
			fuel_empty = true
			can_refuel = false
			
	#Refuel JetPack logic
	if can_refuel == true:
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
	else:
		if wait_to_refuel: return
		wait_to_refuel = true
		jetpack_reful_anim_player.play("jetpack_empty")
		refuel_timer.start()
		await refuel_timer.timeout
		jetpack_reful_anim_player.stop()
		jetpack_reful_anim_player.play("RESET")
		wait_to_refuel = false
		can_refuel = true
		

# handle gun direction and actions
func _handle_gun(gun_direction, gun_facing_left):
	# Handle Gun Inputs
	if Input.is_action_pressed("attack"):
		gun._shoot()
	
	gun._setup_direction(gun_direction, gun_facing_left)


func knockback(enemyVelocity: Vector2):
	var knockback_direction
	if enemyVelocity != Vector2(0.0,0.0) && velocity != Vector2(0.0, 0.0):
		knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	elif enemyVelocity == Vector2(0.0,0.0) && velocity != Vector2(0.0, 0.0):
		enemyVelocity = velocity * -1
		knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	else:
		enemyVelocity = Vector2(knockback_power, knockback_power) * -1
		knockback_direction = (enemyVelocity - velocity).normalized() * knockback_power
	velocity = knockback_direction
	move_and_slide()
	
# handle all player movement
func _player_movement(player_delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * player_delta

	#Animations
	if (velocity.x > 1 || velocity.x < -1):
		_animations("running")
	else:
		_animations("default")
	
	if not is_on_floor():
		_animations("jumping")

	# Get the input direction and handle the movement/deceleration.
	player_direction = Input.get_axis("left", "right")
	
	if player_direction && is_knockedback == false:
		velocity.x = player_direction * speed
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
		is_left = true
		player_sprite.flip_h = is_left
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
		elif thumb_stick_direction != Vector2(0,0):
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))

		_handle_gun(thumb_stick_direction, is_left)
		
	elif Input.is_action_pressed("right"):
		default_direction = Vector2.RIGHT
		is_left = false
		player_sprite.flip_h = is_left
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
		elif thumb_stick_direction != Vector2(0,0):
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
			
		_handle_gun(thumb_stick_direction, is_left)
	else:
		if thumb_stick_direction == Vector2(0,0):
			thumb_stick_direction = default_direction
		else:
			thumb_stick_direction = Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		
		if default_direction == Vector2(1,0):
			is_left = false
		else:
			is_left = true
		_handle_gun(thumb_stick_direction, is_left)
		
	# jetpack movement call
	_jetPack(player_direction)

# main physics process
func _physics_process(delta: float) -> void:
	if is_dead == false:
		# player movement call
		_player_movement(delta)
		
		move_and_slide()

func _on_health_component_died() -> void:
	is_dead = true
	set_process_input(false)
	_animations("death")
	respawn_timer.start()
	await respawn_timer.timeout
	player_respawned.emit()
	velocity = Vector2.ZERO
	is_dead = false
	set_process_input(true)
	_animations("default")


func _on_hurt_box_knockback(area: Area2D) -> void:
	if is_hurt: return
	is_hurt = true
	is_knockedback = true
	player_hurtbox.set_collision_mask_value(4, false)
	knockback(area.get_parent().velocity)
	_hurt_timer()
	knockback_timer.start()
	await knockback_timer.timeout
	is_knockedback = false
	is_hurt = false
	
func _hurt_timer():
	hit_flash_anim_player.play("hit_flash")
	hurt_timer.start()
	await hurt_timer.timeout
	hit_flash_anim_player.stop()
	player_sprite.modulate = Color.WHITE
	player_hurtbox.set_collision_mask_value(4, true)
	

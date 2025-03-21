class_name health_component extends Node

signal died
@export var health: float
@export var hurt_box: hurtBox
@export var health_bar: TextureProgressBar

func _ready() -> void:
	health_bar.value = health
	if health_bar.value == health_bar.max_value:
		health_bar.visible = false
	hurt_box.damage_taken.connect(damage_taken)

func damage_taken(damage: float) -> void:
	health -= damage
	health_bar.value = health
	health_bar.visible = true
	if health <= 0:
		died.emit()

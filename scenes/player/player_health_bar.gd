class_name PlayerHealthBar extends TextureProgressBar

@export var player: Player

#func _ready() -> void:
	#update()
#
#
#func update():
	#value = player.current_health * 100 / player.max_health
	

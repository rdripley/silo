class_name Spawner extends Node2D

@onready var player_marker: Marker2D = %PlayerRespawnLocation
@onready var enemy_marker: Marker2D = %EnemyRespawnLocation

func _ready() -> void:
	for player in get_tree().get_nodes_in_group("Player"):
		player.player_respawned.connect(_on_player_respawned.bind(player))
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.enemy_respawned.connect(_on_enemy_respawned.bind(enemy))
		
		
func _on_player_respawned(player):
	player.global_position = player_marker.global_position
	
func _on_enemy_respawned(enemy):
	enemy.global_position = enemy_marker.global_position

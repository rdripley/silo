extends Camera2D

func _on_level_1_node_ready(level_node, level_map) -> void:
	var current_node = get_tree().get_current_scene().get_node(level_node)
	var current_level = current_node.get_child(level_map)
	var mapRect = current_level.get_used_rect()
	var tileSize = current_level.rendering_quadrant_size * current_node.scale.x
	var worldSizeInPixels = mapRect.size * tileSize
	limit_right = worldSizeInPixels.x
	limit_bottom = worldSizeInPixels.y

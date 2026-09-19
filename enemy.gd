extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.on_enemy_destroyed()

		#var old_scale = Engine.time_scale
		#Engine.time_scale = 0.05
		#await get_tree().create_timer(0.04, true, false, true).timeout
		#Engine.time_scale = old_scale

		queue_free()

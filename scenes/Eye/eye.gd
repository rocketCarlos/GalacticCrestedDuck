extends Area2D

'''
Eye ball enemy

First, it is slow. When hit by the first time, it gets angry and moves faster. 
Always moves towards the player
'''

#region scene nodes
@onready var sprite = $AnimatedSprite2D
@onready var core = $EnemyCore
@onready var angry_timer = $AngryTimer
@onready var hit_sound = $Hit
@onready var damage_timer = $DamageTimer
@onready var damage_area = $CollisionShape2D
#endregion

#region attributes
var default_speed = 75
var angry_speed = 150
var current_speed: float
# 0 is default, 1 is angry
var behaviour: int: 
	set(value):
		if value != 0 and value != 1:
			printerr('Invalid behaviour assignment on eyeball: ', value, self)
		else:
			behaviour = value
			if behaviour == 0:
				sprite.play("default")
				current_speed = default_speed
			else:
				sprite.play("angry")
				current_speed = angry_speed

# defines an offest from the target when the eye is far from the duck
var goal_randomness: Vector2
var random_range = 20.0
# the distance at which goal_randomness is not added any more to the target position
var random_threshold = 75.0

var evaporating = false
var evaporating_progress = 0.0
var evaporation_duration = 0.37
#endregion

#region ready and process
func _ready() -> void:
	behaviour = 0
	core.hp = 3
	core.type = Globals.MOB_TYPE.EYE
	goal_randomness = Vector2(randf_range(-random_range, random_range), randf_range(-random_range, random_range))
	sprite.material = sprite.material.duplicate()

func _process(delta: float) -> void:
	if not evaporating:
		# set the target position
		var target_position = Globals.duck.global_position
		# add goal_randomness if above the threshold
		if global_position.distance_to(target_position) > random_threshold:
			target_position += goal_randomness
			
		var direction = (target_position - global_position).normalized()
		rotation = Vector2(0.0, 1.0).angle_to(direction)
		
		position += direction * current_speed * delta
	else:
		# Incrementa el progreso basado en el delta y la duración
		evaporating_progress += delta / evaporation_duration
		if evaporating_progress >= 1.0:
			evaporating_progress = 1.0
			evaporating = false
			queue_free() # Elimina el nodo al final del efecto

		# Actualiza el parámetro del shader
		sprite.material.set_shader_parameter("progress", evaporating_progress)
#endregion

#region signal functions
func _on_area_entered(area: Area2D) -> void:
	# eye gets angry when hit
	behaviour = 1
	angry_timer.start()
	core.hit()
	# If lost all hp, stop taking damage and start evaporating
	if core.hp <= 0:
		evaporating = true
		sprite.material.set_shader_parameter("enabled", true)
		damage_area.set_deferred("disabled", true)
		core.die()
		
	# play the hit sound and show the hit animation
	hit_sound.play()
	damage_timer.start()
	modulate = Color(1, 0, 0)
	
func _on_angry_timer_timeout() -> void:
	# eye turns back to normal after the timeout
	behaviour = 0
	
func _on_damage_timer_timeout() -> void:
	modulate = Color(1, 1, 1)
#endregion

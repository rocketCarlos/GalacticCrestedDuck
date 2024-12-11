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
#endregion

#region attributes
var default_speed = 75
var angry_speed = 175
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
#endregion

#region ready and process
func _ready() -> void:
	behaviour = 0
	core.hp = 4
	goal_randomness = Vector2(randf_range(-random_range, random_range), randf_range(-random_range, random_range))

func _process(delta: float) -> void:
	# set the target position
	var target_position = Globals.duck.global_position
	# add goal_randomness if above the threshold
	if global_position.distance_to(target_position) > random_threshold:
		target_position += goal_randomness
		
	var direction = (target_position - global_position).normalized()
	rotation = Vector2(0.0, 1.0).angle_to(direction)
	
	position += direction * current_speed * delta
#endregion

#region signal functions
func _on_area_entered(area: Area2D) -> void:
	# eye gets angry when hit
	behaviour = 1
	angry_timer.start()
	core.hit()
	# despawn if lost all hp
	if core.hp <= 0:
		queue_free()

func _on_angry_timer_timeout() -> void:
	# eye turns back to normal after the timeout
	behaviour = 0
#endregion

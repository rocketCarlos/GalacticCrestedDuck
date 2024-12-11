extends Area2D

'''
Laser

Represents the a "bullet" of the Galactic Duck laser gun. When instantiated, it moves at a certain
velocity set by the attribute speed in the direction set by the attribute direction. The laser is 
meant to be instantiated by the duck when firing a shot, setting the desired direction in the 
process. The laser is automatically destroyed after travelling the distance set by the attribute
max_distance
'''

#region attributes
# direction is expected to be a normalized vector 
var direction = Vector2(1, 0)
var speed = 800
var max_distance = 800
var travelled = 0
#endregion

#region ready and process
func _ready() -> void:
	rotation = Vector2(0.0, 1.0).angle_to(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# bullet disappears when travelled max_distance units
	if travelled >= max_distance:
		queue_free()
	
	position += direction * speed * delta
		
	travelled += (direction * speed * delta).length() 	
#endregion

#region signal functions
func _on_area_entered(area: Area2D) -> void:
	queue_free()
#endregion

extends CharacterBody2D


var direction = Vector2(1, 0)
var speed = 800
var max_distance = 800
var travelled = 0

func _ready() -> void:
	velocity = direction * speed
	rotation = Vector2(0.0, 1.0).angle_to(direction)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# bullet disappears when travelled max_distance units
	travelled += velocity.length() * delta 
	if travelled >= max_distance:
		queue_free()
		
	move_and_slide()

func _on_area_entered(area):
	queue_free()

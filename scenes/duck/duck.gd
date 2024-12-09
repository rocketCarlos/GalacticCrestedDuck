extends CharacterBody2D

@onready var sprite = $Sprite2D

const MAX_SPEED = 300.0
const ACCEL_PER_SECOND = 600.0

func _ready() -> void:
	velocity = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	# -----------------------------------------
	# rotate the duck to point towars the mouse
	# -----------------------------------------
	var mouse_position = get_global_mouse_position()
	var direction = (mouse_position - global_position).normalized()
	rotation = Vector2(0.0, 1.0).angle_to(direction)
	# -----------------------------------------
	# manage speed
	# -----------------------------------------
	if Input.is_action_pressed("Accelerate"):
		velocity += ACCEL_PER_SECOND * direction * delta
		# Limit speed not to exceed MAX_SPEED
		if velocity.length() >= MAX_SPEED:
			velocity = velocity.normalized() * MAX_SPEED
	else:
		if velocity.length() > 0:
			velocity -= velocity.normalized() * ACCEL_PER_SECOND * delta
			# Prevent overshooting and stop when speed is very low
			if velocity.length() < 1.0:  # Threshold for stopping
				velocity = Vector2(0, 0)
		
	move_and_slide()

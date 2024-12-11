extends CharacterBody2D

'''
Duck

This is the Galactic Duck that the player plays as. It can shoot with left click and move with right
click. When holding right click, the duck accelerates towards the mouse position. When right click 
is released, the duck deaccelerates. Params to define the movement behaviour are MAX_SPEED,  
ACCEL_PER_SECOND and DEACCEL_PER_SECOND. User can hold left click to shoot, being the fire rate set by fire_rate
'''

#region scene nodes
@onready var sprite = $Sprite2D
@onready var gun_position = $GunPosition
@onready var hit_timer = $HitTimer
@onready var damage_hitbox = $DamageArea/DamageHitbox
#endregion

enum STATE {
	DEFAULT,
	HIT,
	DEAD
}

#region attributes
@export var laser_scene: PackedScene

var current_state = STATE.DEFAULT

const MAX_SPEED = 300.0
const ACCEL_PER_SECOND = 600.0
const DEACCEL_PER_SECOND = 300.00

var last_shot = 0 # time since last fired shot
var fire_rate = 140 # in milliseconds

var hp = 25
#endregion

#region ready and process
func _ready() -> void:
	velocity = Vector2(0, 0)
	Globals.duck = self

func _physics_process(delta: float) -> void:
	match current_state:
		STATE.DEAD:
			# if dead, do nothin
			pass
		
		_: # if default or hit, act normally
			# -----------------------------------------
			# rotate the duck to point towars the mouse
			# -----------------------------------------
			var mouse_position = get_global_mouse_position()
			var direction = (mouse_position - global_position).normalized()
			rotation = Vector2(0.0, 1.0).angle_to(direction)
			# -----------------------------------------
			# manage shooting
			# -----------------------------------------
			var can_shoot = false
			var now = Time.get_ticks_msec()
			if (now - last_shot) >= fire_rate:
				can_shoot = true
			
			if Input.is_action_pressed("Shoot") and can_shoot:
				last_shot = now
				var laser = laser_scene.instantiate()
				laser.direction = direction
				laser.global_position = gun_position.global_position
				add_sibling(laser)
			# -----------------------------------------
			# manage movement
			# -----------------------------------------
			if Input.is_action_pressed("Accelerate"):
				velocity += ACCEL_PER_SECOND * direction * delta
				# Limit speed not to exceed MAX_SPEED
				if velocity.length() >= MAX_SPEED:
					velocity = velocity.normalized() * MAX_SPEED
			else:
				if velocity.length() > 0:
					velocity -= velocity.normalized() * DEACCEL_PER_SECOND * delta
					# Prevent overshooting and stop when speed is very low
					if velocity.length() < 10.0:  # Threshold for stopping
						velocity = Vector2(0, 0)
						
			move_and_slide()
#endregion


#region signal functions
func _on_damage_area_area_entered(area: Area2D) -> void:
	# when hit, start the immunity time
	current_state = STATE.HIT
	hit_timer.start()
	damage_hitbox.set_deferred(&"disabled", true)
	
	hp -= 1
	if hp <= 0:
		current_state = STATE.DEAD
		
func _on_hit_timer_timeout() -> void:
	# when the hit timer ends, go back to default mode and collisions are registered again
	damage_hitbox.set_deferred(&"disabled", false)
	current_state = STATE.DEFAULT
#endregion

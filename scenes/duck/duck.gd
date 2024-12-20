extends CharacterBody2D

'''
Duck

This is the Galactic Duck that the player plays as. It can shoot with left click and move with right
click. When holding right click, the duck accelerates towards the mouse position. When right click 
is released, the duck deaccelerates. Params to define the movement behaviour are MAX_SPEED,  
ACCEL_PER_SECOND and DEACCEL_PER_SECOND. User can hold left click to shoot, being the fire rate set 
by fire_rate * fire_rate_multiplier
'''

#region scene nodes
@onready var sprite = $Sprite2D
@onready var gun_position = $GunPosition
@onready var hit_timer = $HitTimer
@onready var damage_animation_timer = $HitTimer/DamageAnimationTimer
@onready var damage_hitbox = $DamageArea/DamageHitbox
@onready var laser_sound = $LaserSound
@onready var hit_sound = $Hit
@onready var fire_rate_timer = $ItemPickUp/IncreasedFireRate
@onready var item_sound = $ItemPickUp/ItemSound
#endregion

enum STATE {
	DEFAULT,
	HIT,
	DEAD
}

enum ITEMS {
	STRAWBERRY_MILK,
	GREEN_TEA,
	
}

#region attributes
@export var laser_scene: PackedScene

var current_state

const MAX_SPEED = 300.0
const ACCEL_PER_SECOND = 650.0
const DEACCEL_PER_SECOND = 250.00

const LASER_THRESHOLD = 225.0

var last_shot = 0 # time since last fired shot
var fire_rate = 140 # in milliseconds
var fire_rate_multiplier = 1.0 # multiplier for item effects

var hp: int

# ensures that the duck is hit only once per frame
var already_hit: bool
#endregion

#region restart, ready and process
# called when the main scene emits the signal to restart the game
func _restart() -> void:
	velocity = Vector2(0, 0)
	Globals.duck = self
	already_hit = false
	current_state = STATE.DEFAULT
	hp = 15
	damage_hitbox.set_deferred(&"disabled", false)

func _ready() -> void:
	current_state = STATE.DEAD
	Globals.restart.connect(_restart)
	Globals.item_picked_up.connect(_on_item_picked_up)

func _physics_process(delta: float) -> void:
	already_hit = false
	match current_state:
		STATE.DEAD:
			# if dead, do nothing
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
			if (now - last_shot) >= fire_rate * fire_rate_multiplier:
				can_shoot = true
			
			if Input.is_action_pressed("Shoot") and can_shoot:
				last_shot = now
				var laser = laser_scene.instantiate()
				# decide the laser direction depending on the distance to the mouse
				if global_position.distance_to(mouse_position) > LASER_THRESHOLD:
					# if far away, shoot pointing exactly at the mouse
					laser.direction = (mouse_position - gun_position.global_position).normalized()
				else:
					# if too close, shoot straight
					laser.direction = direction
				
				laser.global_position = gun_position.global_position
				add_sibling(laser)
				laser_sound.play()
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
	if not already_hit:
		hp -= 1
		Globals.duck_hit.emit()
		already_hit = true
		if hp <= 0:
			current_state = STATE.DEAD
			Globals.game_over.emit()
		else:
			# when hit, start the immunity time and animation time
			current_state = STATE.HIT
			hit_timer.start()
			damage_animation_timer.start()
			
		damage_hitbox.set_deferred(&"disabled", true)
		
		hit_sound.play()

		
		
func _on_hit_timer_timeout() -> void:
	# when the hit timer ends, go back to default mode and collisions are registered again
	damage_hitbox.set_deferred(&"disabled", false)
	current_state = STATE.DEFAULT


func _on_damage_animation_timer_timeout() -> void:
	# if state is hit, alternate visibility for blink effect
	if current_state == STATE.HIT:
		visible = not visible
		damage_animation_timer.start()
	#else, keep the duck visible
	else:
		visible = true

func _on_item_picked_up(type: Globals.ITEMS) -> void:
	item_sound.play()
	match type:
		Globals.ITEMS.VANILLA_CHAI:
			fire_rate_multiplier = 0.5
			fire_rate_timer.start(Globals.item_times[type])
		Globals.ITEMS.STRAWBERRY_MILK:
			hp += 2


func _on_increased_fire_rate_timeout() -> void:
	fire_rate_multiplier = 1
#endregion

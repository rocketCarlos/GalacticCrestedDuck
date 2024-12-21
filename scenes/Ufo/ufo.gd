extends Area2D

'''
ufo

Enemy that wanders around outside the ellipse and stops to aim a laser beam agains the player
'''

#region scene nodes
@onready var ufo_animation = $Sprite2D
@onready var laser_beam = $Sprite2D/LaserBeam
@onready var core = $EnemyCore
@onready var behaviour_timer = $BehaviourTimer
@onready var damage_timer = $DamageTimer
@onready var loading_timer = $BehaviourTimer/LoadingLaser
@onready var locking_timer = $BehaviourTimer/Locking
@onready var hit_sound = $Hit
@onready var laser_sound = $LaserSound
@onready var laser_position = $LaserPosition
#endregion

@export var laser_scene: PackedScene
var laser

const ROTATION_OFFSET = -45.0
# laser beam loading time
const LOADING_TIME = 5.0
# laser beam locking time
const LOCKING_TIME = 0.37

enum BEHAVIOUR {
	WANDERING,
	AIMING,
	LOCKING,
	SHOOTING
}

var wandering_target

var current_behaviour: BEHAVIOUR:
	set(value):
		current_behaviour = value
		
		match value:
			BEHAVIOUR.WANDERING:
				ufo_animation.play("default")
				
			BEHAVIOUR.AIMING:
				laser_sound.play()
				ufo_animation.play("loading1")
				manage_laser_animations()
				loading_timer.start()
				await ufo_animation.animation_looped
				ufo_animation.play("loading2")
				
			BEHAVIOUR.LOCKING:
				# show laser
				var opacity_tween = get_tree().create_tween()
				opacity_tween.tween_property(laser_beam, "modulate", Color(1, 1, 1, 0.85),  LOCKING_TIME)
				opacity_tween.tween_property(laser_beam, "modulate", Color.TRANSPARENT,  0.1)
				# prepare the laser shot
				laser = laser_scene.instantiate()
				laser.direction = (Globals.duck.global_position - global_position).normalized()
				laser.global_position = laser_position.global_position
				laser.collision_layer = 4
				laser.collision_mask = 1
				
				locking_timer.start()

#region ready and process
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	core.hp = 2
	core.type = Globals.MOB_TYPE.UFO
	
	set_target()
	
	current_behaviour = BEHAVIOUR.WANDERING
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_behaviour:
		BEHAVIOUR.WANDERING:
			pass
		BEHAVIOUR.AIMING:
			# set the target position
			var target_position = Globals.duck.global_position
				
			var direction = (target_position - global_position).normalized()
			rotation_degrees = (Vector2(0.0, 1.0).angle_to(direction)*180.0/PI) + ROTATION_OFFSET
		
		BEHAVIOUR.LOCKING:
			# do nothing
			pass
		BEHAVIOUR.SHOOTING:
			# shoot laser
			add_sibling(laser)
			current_behaviour = BEHAVIOUR.WANDERING
			set_target()
#endregion

#region utility functions
func manage_laser_animations() -> void:
	await ufo_animation.animation_looped
	laser_beam.show()
	laser_beam.modulate = Color(1, 1, 1, 0)
	var opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(laser_beam, "modulate", Color(1, 1, 1, 0.75), 
	LOADING_TIME-1.6).set_trans(Tween.TRANS_BOUNCE)
	
# function that gets a new target for the ufo and makes it travel there
func set_target() -> void:
	if Globals.spawn_system:
		wandering_target = Globals.spawn_system.get_ufo_position_target()
		
		var position_tweener = get_tree().create_tween()
		position_tweener.tween_property(self, "position", wandering_target, 5).set_trans(Tween.TRANS_SINE)
		
		behaviour_timer.start(5)
#endregion

#region signal functions
# when hit by laser
func _on_area_entered(area: Area2D) -> void:
	core.hit()
	# despawn if lost all hp
	if core.hp <= 0:
		core.die()
		queue_free()
	# play the hit sound and show the hit animation
	hit_sound.play()
	damage_timer.start()
	modulate = Color(1, 0, 0)


func _on_damage_timer_timeout() -> void:
	modulate = Color(1, 1, 1)


func _on_behaviour_timer_timeout() -> void:
	
	current_behaviour = BEHAVIOUR.AIMING
	
func _on_loading_laser_timeout() -> void:
	current_behaviour = BEHAVIOUR.LOCKING
	
func _on_locking_timeout() -> void:
	# after timeout, shooot
	current_behaviour = BEHAVIOUR.SHOOTING
#endregion

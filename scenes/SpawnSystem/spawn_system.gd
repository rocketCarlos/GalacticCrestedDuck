extends Node

'''
Spawn system

Manages the spawn of enemies. Each enemy has an array where it is specified their spawning rate.
Each array has elements that follow this format:
	{"ACTION": "wait", "TIME": <waiting_time> } 
	or 
	{"ACTION": "spawn", "INTERVAL": <seconds_between_spawns>, "GROUP": <amount>, "TIMES": <total_spawns>}
	
ACTION can be:
	- WAIT: waits for an amount of time without spawning enemies of that type
	- SPAWN: spawns that type of enemy in a specified time interval in groups of a specified amount 
	a specified amount of times
	
When one "task" is done, the spawner advances to the next task (the following element in the array).
When reached the last task, the last defined task is repeated undefinedly (or until the player loses).

Mobs are spawned along a Path2D that covers the game's screen


'''
@onready var path = $Path2D/PathFollow2D
@onready var ufo_path = $UfoPath/PathFollow2D

#region enemies
@export var eye_scene: PackedScene
@export var ufo_scene: PackedScene
#endregion


#region spawning definitions
var eyes = [
	{"ACTION": "spawn", "INTERVAL": 2, "GROUP": 1, "TIMES": 5},
	{"ACTION": "wait", "TIME": 5},
	{"ACTION": "spawn", "INTERVAL": 2, "GROUP": 2, "TIMES": 8},
	{"ACTION": "wait", "TIME": 4},
	{"ACTION": "spawn", "INTERVAL": 4, "GROUP": 4, "TIMES": 5},
	{"ACTION": "wait", "TIME": 5},
	{"ACTION": "spawn", "INTERVAL": 0.75, "GROUP": 1, "TIMES": 40},
	{"ACTION": "wait", "TIME": 0.75},
	{"ACTION": "spawn", "INTERVAL": 0.60, "GROUP": 1, "TIMES": 10000},
]


var ufos = [
	{"ACTION": "wait", "TIME": 110},
	{"ACTION": "spawn", "INTERVAL": 10, "GROUP": 1, "TIMES": 5},
	{"ACTION": "wait", "TIME": 10},
	{"ACTION": "spawn", "INTERVAL": 5, "GROUP": 1, "TIMES": 5},
	{"ACTION": "wait", "TIME": 5},
	{"ACTION": "spawn", "INTERVAL": 5, "GROUP": 2, "TIMES": 10000},
]
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	manage_spawns(eyes, eye_scene)
	manage_spawns(ufos, ufo_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# function to spawn any kind of mob by using its array of actions
func manage_spawns(rules: Array, mob: PackedScene) -> void:
	var idx = 0
	
	while(true):
		match rules[idx]["ACTION"]:
			"spawn":
				for i in range(rules[idx]["TIMES"]):
					for j in range(rules[idx]["GROUP"]):
						spawn(mob)
					# wait the specified time until spawning again, unless it was the last group of mobs
					if i < (rules[idx]["TIMES"]-1):
						await get_tree().create_timer(rules[idx]["INTERVAL"]).timeout
			
			"wait":
				await get_tree().create_timer(rules[idx]["TIME"]).timeout
				
			_:
				printerr("Invalid action in mob spawner: ", rules[idx]["ACTION"], " in ", mob)
			
		# advance to the next rule unless there are no more rules
		if idx < (rules.size()-1):
			idx += 1
	
					
func spawn(mob: PackedScene) -> void:
	# Create a new instance of the Mob scene.
	var instance = mob.instantiate()

	# Choose a random location on Path2D.
	path.progress_ratio = randf()

	# Set the mob's position to a random location.
	instance.position = path.position

	# Spawn the mob by adding it to the scene.
	add_sibling(instance)

func get_ufo_position_target() -> Vector2:
	ufo_path.progress_ratio = randf()
	return ufo_path.position

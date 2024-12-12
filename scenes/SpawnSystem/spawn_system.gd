extends Node

'''
Spawn system

Manages the spawn of enemies. Each enemy has an array where it is specified their spawning rate.
Each array has elements that follow this format:
	{"ACTION": "wait", "TIME": <waiting_time> } 
	or 
	{"ACTION": "spawn", "INTERVAL": <seconds_between_spawns>, "GROUP": <amount>, "UNTIL": <total_spawned_mobs>}
	
ACTION can be:
	- WAIT: waits for an amount of time without spawning enemies of that type
	- SPAWN: spawns that type of enemy in a specified time interval in groups of a specified amount 
	until a specified amount of enemies are spawned
	
When one "task" is done, the spawner advances to the next task (the following element in the array).
When reached the last task, the last defined task is repeated undefinedly
'''

#region enemies
@export var eye_scene: PackedScene
#endregion



#region spawning definitions
var eyes = [
	{"ACTION": "spawn", "INTERVAL": 3, "GROUP": 1, "UNTIL": 5},
	{"ACTION": "wait", "TIME": 5},
	{"ACTION": "spawn", "INTERVAL": 2, "GROUP": 2, "UNTIL": 10}
]
#endregion


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

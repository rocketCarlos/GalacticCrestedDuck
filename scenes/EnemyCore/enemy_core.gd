extends Node

'''
EnemyCore

Represents the common behaviour across all enemies:
	- enemies have a certain amount of health points
	- enemies lose HP when hit
	- enemies despawn when they lose all HP
	- enemies know the duck's position and may go towards him
	
Enemies are meant to have this node as a child and use its functions to perform common enemy logic
'''

#region attributes
var hp: int
#endregion

#region ready and process
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
#endregion

#region CORE FUNCTIONS
'''
Called when the enemy is hit. If HP reaches 0, 
'''
func hit() -> void:
	hp -= 1

'''
Called when the enemy dies to free the node and compute score
'''
func die() -> void:
	Globals.mob_despawned.emit()
	
#endregion

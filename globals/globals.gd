extends Node

'''
Autoloaded script for globals
'''

# reference to the duck
var duck
#reference to the spawn system
var spawn_system
# the center of the screen
const CENTER_POINT = Vector2(573.0, 326.0) 

# signal emitted by the main scene node to restart the game
signal restart
# emitted by the duck when the game ends
signal game_over
# when a mob despawns, it sends this signal to add score
signal mob_despawned(type: MOB_TYPE)
# when the duck is hit, it sends this signal to update the health display
signal duck_hit
# when an item is picked up, the duck applies effect, the item disappears and info of the active
# effect is shown in the screen
signal item_picked_up(type: ITEMS)

enum ITEMS {
	VANILLA_CHAI, # increases fire rate
	STRAWBERRY_MILK, # gives hp
	PHO, # gives a shield and invulnerability
}

enum MOB_TYPE {
	EYE,
	UFO
}

# amount of time that an effect is active
var item_times = {
	ITEMS.VANILLA_CHAI: 7.0, # seconds of increased fire_rate
	ITEMS.PHO: 5.0, # seconds of shield and invulnerability
}

# function that generates and return a random point contained in the ellipse that approximates the
# playable area
func get_random_point_in_ellipse() -> Vector2:
	var point = get_outline_point_in_ellipse()
	
	var x = lerp(0.0, point.x, randf())
	var y = lerp(0.0, point.y, randf())
	# Add CENTER POINT to offset the points towards the center
	return Vector2(x, y) + CENTER_POINT
	
# gets a point that is in the outline of the ellipse that apporoximates the playable area
func get_outline_point_in_ellipse() -> Vector2:
	# magic numbers are the semiaxis of the pseudoellipse collider
	var ellipse_width = 964.0 / 2.0 
	var ellipse_height = 539.0 / 2.0
	
	# get a random point in x axis
	var x = randf_range(-ellipse_width+1.0, ellipse_width-1.0) # add 1 to avoid value 0 for the y
	# get one of the possible y values (the positive one) using the ellpise formula
	var y = (ellipse_height/ellipse_width)*sqrt(ellipse_width*ellipse_width - x*x)
	# now, randomly select the other possible y value
	if randf() > 0.5:
		y = - y
	
	return Vector2(x, y)

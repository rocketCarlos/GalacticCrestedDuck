extends Node

'''
Autoloaded script for globals
'''

# reference to the duck
var duck

# signal emitted by the main scene node to restart the game
signal restart
# emitted by the duck when the game ends
signal game_over
# when a mob despawns, it sends this signal to add score
signal mob_despawned
# when the duck is hit, it sends this signal to update the health display
signal duck_hit
# when an item is picked up, the duck applies effect, the item disappears and info of the active
# effect is shown in the screen
signal item_picked_up(type: ITEMS)

enum ITEMS {
	VANILLA_CHAI, # increases fire rate
	STRAWBERRY_MILK # gives hp
}

# amount of time that an effect is active
var item_times = {
	ITEMS.VANILLA_CHAI: 10.0, # seconds of increased fire_rate
}

# function that generates and return a random point contained in the ellipse that approximates the
# playable area
func get_random_point_in_ellipse() -> Vector2:
	var point = get_outline_point_in_ellipse()
	
	var x = lerp(0.0, point.x, randf())
	var y = lerp(0.0, point.y, randf())
	return Vector2(x, y) + (get_tree().root.size / 2.0)
	
# gets a point that is in the outline of the ellipse that apporoximates the playable area
func get_outline_point_in_ellipse() -> Vector2:
	var ellipse_width = 964.0 / 2.0
	var ellipse_height = 539.0 / 2.0
	
	# get a random point in x
	var x = randf_range(-ellipse_width, ellipse_width)
	var y = sqrt((1.0 - (x*x)/(ellipse_width*ellipse_width)) * (ellipse_height*ellipse_height))
	if randf() > 0.5:
		y = - y
	
	return Vector2(x, y)

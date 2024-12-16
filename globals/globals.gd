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

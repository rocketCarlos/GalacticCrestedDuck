extends Node

'''
Autoloaded script for globals
'''

# reference to the duck
var duck

# when a mob despawns, it sends this signal to add score
signal mob_despawned
# when the duck is hit, it sends this signal to update the health display
signal duck_hit

extends Node

'''
Item spawn system

Node that manages the spawning of items

It spawns items according to the spawning rules inside the ellipse that approximates the playable
area
'''

#region scene nodes
@onready var spawn_timer = $SpawnTimer
@onready var tea_effect_timer = $VanillaChai/EffectTimer
@onready var vanilla_chai = $VanillaChai
#endregion

var tea_picked = false

@export var item_scene : PackedScene

# array of bools. 0 for inactive items, 1 for active items
var active_items = [0, 0]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.item_picked_up.connect(_on_item_picked_up)
	# spawn_timer.start( 7 + randf() * 10)
	spawn_timer.start(5)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_spawn_timer_timeout() -> void:
	var item = item_scene.instantiate()
	item.type = randi_range(0, Globals.ITEMS.size()-1)
	item.global_position = Globals.get_random_point_in_ellipse()
	add_child(item)
		
	#spawn_timer.start( 7 + randf() * 10)
	spawn_timer.start(5)


func _on_effect_timer_timeout() -> void:
	tea_picked = false
	# when the effect is gonna end, blink the item for 2 seconds
	for i in range(20):
		vanilla_chai.visible = not vanilla_chai.visible
		await get_tree().create_timer(0.1).timeout
		# in case the player picked up another tea, abort
		if tea_picked:
			return
		
	vanilla_chai.hide()
	
		
func _on_item_picked_up(type: Globals.ITEMS) -> void:
	# show info status
	if type == Globals.ITEMS.VANILLA_CHAI:
		tea_picked = true
		vanilla_chai.show()
		tea_effect_timer.start(Globals.item_times[Globals.ITEMS.VANILLA_CHAI] - 2)

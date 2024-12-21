extends AnimatedSprite2D

'''
Item

Node that represents an item. Item types are declared in Globals. Item effects are managed by the 
duck
'''

@onready var time_alive = $TimeAlive
@onready var timer_final = $TimeAlive/TimerFinalAnimation

# counts the number of times that the sprite has blinked before disappears
var final_count

var type : Globals.ITEMS:
	set(value):
		type = value
		match value:
			Globals.ITEMS.STRAWBERRY_MILK:
				animation = "StrawberryMilk"
			Globals.ITEMS.VANILLA_CHAI:
				animation = "VanillaChai"
			Globals.ITEMS.PHO:
				animation = "Pho"
			_:
				printerr("INVALID ITEM TYPE ", value, " ", self)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_alive.start(7 + randf() * 5)
	final_count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	# emit signal and despawn
	Globals.item_picked_up.emit(type)
	queue_free()


func _on_time_alive_timeout() -> void:
	timer_final.start()


func _on_timer_final_animation_timeout() -> void:
	if final_count == 25:
		queue_free()
	else:
		visible = not visible
		final_count += 1
		timer_final.start()

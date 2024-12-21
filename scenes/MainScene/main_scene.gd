extends Node

'''
Main scene

Controls the game flow: 
	- Game over: when the player loses all hp, the duck freezes (its state is DEAD), the spawn
	system is freed for mobs and items and a text is shown along the play button
	- Restart: when the player presses the play button, the game (re)starts, meaning that the 
'''

#region scene nodes
@onready var play_button = $PlayButton
@onready var game_over_text = $PlayButton/GameOverText
@onready var background_music = $BackgroundMusic
@onready var play_sound = $PlayButton/PlaySound
@onready var game_over_sfx = $GameOver
#endregion

# packed scenes scenes
@export var spawn_system_scene: PackedScene
@export var item_system_scene: PackedScene
# reference to the scenes
var spawn_system
var item_system

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_over.connect(_on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#region signal functions
func _on_game_over() -> void:
	spawn_system.queue_free()
	spawn_system = null
	item_system.queue_free()
	item_system = null
	
	play_button.show()
	game_over_text.show()
	
	background_music.stop()
	game_over_sfx.play()

func _on_play_button_pressed() -> void:
	# instantiate the spawn system
	spawn_system = spawn_system_scene.instantiate()
	add_child(spawn_system)
	# instantiate the item system
	item_system = item_system_scene.instantiate()
	add_child(item_system)
	# clear mobs from previous run, if any
	var mobs = get_tree().get_nodes_in_group("Mobs")
	for mob in mobs:
		mob.queue_free()
	# tell everyone to restart
	Globals.restart.emit()
	# hide the play button
	play_button.hide()
	play_sound.play()
	await play_sound.finished
	background_music.play()
#endregion

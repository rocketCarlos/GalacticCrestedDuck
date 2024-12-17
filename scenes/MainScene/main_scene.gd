extends Node

'''
Main scene

Controlls the game flow: 
	- Game over: when the player loses all hp, the duck freezes (its state is DEAD), the spawn
	system is freed (therefore, no more mobs spawn) and a text is shown along the play button
	- Restart: when the player presses the play button, the game (re)starts, meaning that the 
'''

#region scene nodes
@onready var play_button = $PlayButton
@onready var game_over_text = $PlayButton/GameOverText
@onready var background_music = $BackgroundMusic
@onready var play_sound = $PlayButton/PlaySound
#endregion


@export var spawn_system_scene: PackedScene
# reference to the spawn system
var spawn_system

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.game_over.connect(_on_game_over)
	background_music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_game_over() -> void:
	spawn_system.queue_free()
	spawn_system = null
	play_button.show()
	game_over_text.show()

func _on_play_button_pressed() -> void:
	play_sound.play()
	# instantiate the spawn system
	spawn_system = spawn_system_scene.instantiate()
	add_child(spawn_system)
	# clear mobs from previous run, if any
	var mobs = get_tree().get_nodes_in_group("Mobs")
	for mob in mobs:
		mob.queue_free()
	# tell everyone to restart
	Globals.restart.emit()
	# hide the play button
	play_button.hide()

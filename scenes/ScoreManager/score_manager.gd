extends Label

'''
Score Manager

Node that computes and displays the score
'''

@onready var score_label = $Score
@onready var score_timer = $ScoreTimer

const POINTS_PER_SECOND = 1
const POINTS_PER_ELIM = 1
var score: int:
	set(value):
		score = value
		score_label.text = str(score)

func _restart() -> void:
	score = 0
	score_timer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.mob_despawned.connect(_on_mob_despawned)
	Globals.restart.connect(_restart)
	Globals.game_over.connect(_on_game_over)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mob_despawned() -> void:
	score += POINTS_PER_ELIM

func _on_score_timer_timeout() -> void:
	score += 1

func _on_game_over() -> void:
	score_timer.stop()

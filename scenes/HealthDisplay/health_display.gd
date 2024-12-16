extends Sprite2D

'''
Health display

Node that displays the duck's health
'''

@onready var hp_label = $HP

var hp: int:
	set(value):
		hp = value
		hp_label.text = str(hp)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hp = Globals.duck.hp
	Globals.duck_hit.connect(_on_duck_hit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_duck_hit() -> void:
	hp = Globals.duck.hp

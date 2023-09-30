extends Node2D

signal isDead
@onready var playerNode = get_node("Player")
@onready var buttons = get_node("Botones")

func _ready():
	playerNode.connect("isDead", emitPlayerDeath)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func emitPlayerDeath():
	emit_signal("isDead")
	buttons.hide()

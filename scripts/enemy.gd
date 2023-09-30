extends Node2D

@export var speed: int
@onready var animator = get_node("Sprite2D/AnimationPlayer")

func _ready():
	animator.play("enemy_idle")

func _process(delta):
	position.y += speed * delta

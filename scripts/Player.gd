extends CharacterBody2D

@onready var animation = $Marker2D/AnimationPlayer
@onready var marker = $Marker2D
@onready var gravity = 1500
var movement_speed = 200
@onready var canMove = true;
signal isDead
@onready var can_getout = true
@onready var death = false
@onready var sprite = get_node("Marker2D/Sprite2D")
var tapped = false
var sl = false
var sr = false

func _ready():
	animation.play("Idle")
	velocity.y += -800

func _physics_process(delta):
	var horizontal_movement = 0
	if canMove:
		if Input.is_action_just_pressed("ui_left") or sl:
			sl = false
			horizontal_movement -= 1
			move(horizontal_movement)
			velocity.y = -300
			marker.scale.x = -1
			animation.play("RESET")
			animation.play("Side")
		if Input.is_action_just_pressed("ui_right") or sr:
			sr = false
			horizontal_movement += 1
			move(horizontal_movement)
			velocity.y = -300
			marker.scale.x = 1
			animation.play("RESET")
			animation.play("Side")
		if Input.is_action_pressed("ui_accept") or tapped:
			animation.play("Idle")
			velocity.y = -400
			velocity.x = 0
	velocity.y += gravity * delta
	move_and_slide()
	_on_enemy_body_entered()

func move(horizontal_movement):
	velocity.x = horizontal_movement * movement_speed
	move_and_slide()

func _on_collision_container_body_exited(body):
	if body.name == "Player" and can_getout and death == false:
		print("Body exited!")
		death = true
		canMove = false
		gravity = 0
		velocity = Vector2(0, 0)
		movement_speed = 0
		animation.play("death")
		emit_signal("isDead")

func _on_enemy_body_entered():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "Enemy" in collider.name and death == false:
			death = true
			canMove = false
			can_getout = false
			emit_signal("isDead")


func _on_left_button_pressed():
	sl = true

func _on_right_button_pressed():
	sr = true

func _on_tap_button_button_down():
	tapped = true

func _on_tap_button_button_up():
	tapped = false

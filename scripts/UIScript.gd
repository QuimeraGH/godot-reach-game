extends Node2D

@onready var animatorPlayer = $CuentaRegresiva/AnimationPlayer
@onready var cuentaSprite = $CuentaRegresiva

func _ready():
	var mainNode = get_parent()
	mainNode.connect("signalToCount", onSignalFromMain)
	cuentaSprite.hide()
	
	mainNode.connect("messageSignal", onMessageRestart)

func _process(delta):
	pass

func onSignalFromMain():
	print("Cuenta regresiva!")
	cuentaSprite.show()
	animatorPlayer.play("cuenta")
	await get_tree().create_timer(3).timeout
	cuentaSprite.hide()

func onMessageRestart():
	print("Mensaje")
	await get_tree().create_timer(3).timeout

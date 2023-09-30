extends Node2D

var game_started = false
var enemy_scene = preload("res://scenes/Enemy.tscn")
@onready var groundNode = get_node("GroundNode")
var playerCollisionScene = preload("res://scenes/PlayerAndCollide.tscn")
var playerCollisionIns = playerCollisionScene.instantiate()
signal signalToStart
signal signalToCount
var restart = false
@onready var Buttons = get_node("ButtonsNode")
var spawn_delay = 0.8
var spawn_timer = null
@onready var enemiesKilled = 0
@onready var points = get_node("Label")
@onready var videoPlayer = get_node("UI/VideoStreamPlayer")
@onready var background = get_node("UI/Background")
var canIncrement = true

var speed = 0.008
var increasing = false
var canDisappear = false

var decrease_speed = 0.3
var decreaseVolume = false

var canVary = false
var messageOn = false
signal messageSignal

@onready var messageNode = get_node("Message")
var messageShowing = false
var messageSpeed = 0.02
var tappedInit = false
var inMenu = false
var stillCan = true
############################
func _ready():
	points.hide()
	
	playerCollisionIns.connect("isDead", onDead)
	Buttons.hide()
	spawn_timer = Timer.new()
	spawn_timer.add_to_group("timing", true)
	spawn_timer.set_wait_time(spawn_delay)
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	self.add_child(spawn_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if decreaseVolume:
		var target_volume = videoPlayer.get_volume_db() - decrease_speed
		videoPlayer.set_volume_db(target_volume)

	checkEnemies()
	
	if canDisappear:
		changeBackground()
	
	if enemiesKilled == 24:
		background.hide()
		canDisappear = false
		stillCan = false
	
	if restart:
		messageNode.text = obtenerFraseRandom()
		messageNode.show()
		messageNode.modulate.a = 0
		messageShowing = true
		
	if messageShowing:
		messageNode.modulate.a += messageSpeed
	
	if Input.is_action_just_pressed("ui_accept") and game_started == false or restart or tappedInit:
		tappedInit = false
		var timerpapu = get_tree().get_first_node_in_group("timing")
		timerpapu.set_wait_time(0.8)
		spawn_timer.stop()
		decreaseVolume = true
		points.hide()
		background.show()
		game_started = true
		restart = false
		if messageOn == false:
			emit_signal("signalToCount")
		else:
			emit_signal("messageSignal")
		await get_tree().create_timer(3).timeout
		var enemynodes = get_tree().get_nodes_in_group("Enemy")
		for noden in enemynodes:
			noden.queue_free()
		canIncrement = false
		enemiesKilled = 0
		points.text = str(enemiesKilled)
		messageNode.hide()
		messageShowing = false
		messageOn = true
		timerpapu.stop()
		canVary = true
		decreaseVolume = false
		videoPlayer.play()
		videoPlayer.set_volume_db(0.0)
		points.show()
		emit_signal("signalToStart")
		playerCollisionIns = playerCollisionScene.instantiate()
		playerCollisionIns.connect("isDead", onDead)
		add_child(playerCollisionIns)
		enemiesKilled = 0
		await get_tree().create_timer(6).timeout
		canIncrement = true
		stillCan = true
		spawn_timer.start()
		
	if canVary:
		if increasing == false:
			canDisappear = false
			background.modulate.a = 1
			

func _input(event):
	if event is InputEventScreenTouch and game_started == false and restart == false and inMenu == false and event.is_pressed():
		tappedInit = true

func changeBackground():
	var enemynodes = get_tree().get_nodes_in_group("Enemy")
	var playernodes = get_tree().get_nodes_in_group("player")
	if background.modulate.a <= 0:
		increasing = true
	elif background.modulate.a >= 1:
		increasing = false
	
	if increasing:
		background.modulate.a += speed
		for node in enemynodes:
			node.modulate.a += speed
		for node in playernodes:
			node.modulate.a += speed
	else:
		background.modulate.a -= speed
		for node in enemynodes:
			node.modulate.a -= speed
		for node in playernodes:
			node.modulate.a -= speed


func checkEnemies():
	points.text = str(enemiesKilled)

func _on_spawn_timer_timeout():
	var enemy = enemy_scene.instantiate() # instantiate an enemy when the timer times out
	var screen_size = get_viewport().get_visible_rect().size # get the size of the screen
	enemy.position.x = randf_range(0, screen_size.x)
	self.add_child(enemy) # add it as a child of the current node
	canVary = false
	if stillCan:
		canDisappear = true

func onDead():
	inMenu = true
	canDisappear = true
	spawn_timer.stop()
	background.modulate.a = 1
	print("Is dead!")
	Buttons.show()
	canIncrement = false
	
func _on_button_pressed():
	print("Restarting...")
	Buttons.hide()
	points.hide()
	playerCollisionIns.queue_free()
	game_started = false
	groundNode.translate(Vector2(0, -90))
	restart = true

func _on_menu_button_pressed():
	print("Go to menu!")
	inMenu = false
	Buttons.hide()
	game_started = false
	playerCollisionIns.queue_free()
	groundNode.translate(Vector2(0, -90))

func _on_area_2d_body_exited(body):
	if "Enemy" in body.name:
		body.queue_free()
		if canIncrement:
			enemiesKilled += 1
			if enemiesKilled % 10 == 0:
				var timerpapu = get_tree().get_first_node_in_group("timing")
				timerpapu.set_wait_time(timerpapu.wait_time - 0.05 )
				print(timerpapu.wait_time)

#list of phrases

var frases_oscuras := [
	"En la oscuridad, los susurros son más claros que los gritos.",
	"El vacío en mi alma es más oscuro que la noche más profunda.",
	"Los pecados ocultos son los que más pesan en la conciencia.",
	"En el abismo de la soledad, los demonios se hacen amigos.",
	"Los espejos revelan más de lo que quieres ver.",
	"Las sombras en la esquina de tu visión siempre están acechando.",
	"El eco de tus pensamientos retumba en las paredes vacías de tu mente.",
	"El silencio de la noche revela secretos que el día nunca conocerá.",
	"La oscuridad se alimenta de tus miedos, crece con tus pesadillas.",
	"Los ojos que observan desde las sombras nunca parpadean.",
	"En el rincón más oscuro de tu corazón, se esconde tu verdadero yo.",
	"Los pecados nunca se borran, solo se esconden en las sombras.",
	"La niebla de la noche esconde criaturas que la luz del día nunca revelará.",
	"La verdad yace en el fondo de un pozo sin fondo.",
	"El camino hacia el infierno está pavimentado con buenas intenciones.",
	"Los sueños rotos son las pesadillas que nunca se desvanecen.",
	"La risa en medio de la tormenta es más aterradora que el trueno.",
	"En el espejo, tu reflejo te mira con ojos vacíos.",
	"El pecado es una sombra que siempre te sigue.",
	"Las almas perdidas vagan eternamente en busca de redención.",
	"El vacío del tiempo se traga todo lo que conocemos.",
	"La soledad es la prisión más oscura.",
	"El frío de la noche penetra en los huesos y en el alma.",
	"El eco de tus pasos es más fuerte en el abismo.",
	"Los secretos son como cuchillos afilados, siempre cortando la verdad.",
	"La luna llena despierta los demonios que duermen en lo profundo.",
	"La agonía del remordimiento nunca se apaga.",
	"El pecado original nos persigue desde el principio de los tiempos.",
	"Las sombras del pasado nunca te dejarán en paz.",
	"El vacío interior es un abismo sin fondo que devora el alma.",
	"Los secretos más oscuros se esconden en las profundidades del corazón.",
	"En la oscuridad, los recuerdos cobran vida propia.",
	"La culpa es una cadena que arrastra el espíritu hacia lo más profundo.",
	"El pecado susurra, la redención grita en silencio.",
	"El silencio de la noche es el eco de tus peores pesadillas.",
	"Las palabras vacías son el reflejo de un alma hueca.",
	"En el abismo del olvido, los nombres se desvanecen como susurros al viento.",
	"La decadencia de la moral corroe la esencia humana.",
	"Los sueños rotos son los espejos del alma destrozada.",
	"La condenación eterna es el precio del pacto con la oscuridad.",
	"La mirada del diablo quema como el fuego del infierno.",
	"Los lamentos de las almas perdidas llenan el aire de agonía.",
	"La verdad es un espejismo en el desierto de la mentira.",
	"Las manos manchadas de sangre nunca podrán limpiarse completamente.",
	"La sombra del arrepentimiento nunca es suficiente para escapar del abismo.",
	"En el rincón más oscuro de la mente, se esconde la locura.",
	"El pecado es el anzuelo en el que nuestras almas se enredan.",
	"El vacío del tiempo se traga los sueños y las esperanzas.",
	"La penumbra es el abrazo frío de la desesperación.",
	"Los susurros de los muertos nunca descansan en paz.",
	"El eco del pasado resuena en los pasillos de la obsesión.",
	"Las cadenas del remordimiento arrastran a las almas hacia el abismo.",
	"La traición es un cuchillo afilado en la espalda de la confianza.",
	"La oscuridad interior es más profunda que cualquier abismo exterior.",
	"La angustia se esconde detrás de una sonrisa vacía.",
	"La perdición espera en las sombras, paciente como la muerte.",
	"Los corazones rotos son el alimento de los demonios del dolor.",
	"La noche es el espejo de nuestros temores más profundos."
]

func obtenerFraseRandom():
	var indice_random = randi() % frases_oscuras.size()  # Genera un índice aleatorio
	var frase_random = frases_oscuras[indice_random]    # Obtiene la frase correspondiente al índice
	return frase_random

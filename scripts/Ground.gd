extends StaticBody2D

func _ready():
	var mainNode = get_parent()
	mainNode.connect("signalToStart", onSignalFromMain)

func _process(delta):
	pass

func onSignalFromMain():
	var groundHidden = false
	print("Ground: Signal received from main!")
	if not groundHidden:
		self.translate(Vector2(0, 90))
		groundHidden = true

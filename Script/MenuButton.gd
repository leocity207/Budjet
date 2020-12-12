extends OptionButton
signal Function_changed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_popup().connect("id_pressed",self,"_on_function_choose")

func _on_function_choose(id):
	if id==0:
		Global.USED_METHODE="Linear"
		self.text="Linear"
	elif id==1:
		Global.USED_METHODE="Polynomial"
		self.text="Polynomial"
	elif id==2:
		Global.USED_METHODE="Exponential"
		self.text="Exponential"
	else:
		Global.USED_METHODE="Logarithm"
		self.text="Logarithm"
	emit_signal("Function_changed")

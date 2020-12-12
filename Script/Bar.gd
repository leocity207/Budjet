extends VSplitContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Update_Bar_from_month(value,max_month):
	var time=month_to_year(value)
	if time["year"]==0:
		get_node("Bar_container/Time_label").text=str(time["month"])+" M"
	elif time["month"]!=0:
		get_node("Bar_container/Time_label").text=str(time["year"])+" Y "+str(time["month"])+" M"
	else:
		get_node("Bar_container/Time_label").text=str(time["year"])+" Y"
		
	var spliting_fraction=value/max_month
	var spliter_size=self.get_size().y
	var min_bar_size=50
	var total_range=spliter_size-min_bar_size
	var new_spliter_value=spliting_fraction*total_range
	self.split_offset=spliter_size-new_spliter_value-min_bar_size
	
func month_to_year(month):
	return {"month":month%12,"year":int(floor(month/12))}
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init_bar(name):
	get_node("Bar_container/Bar/Name_label").text=name

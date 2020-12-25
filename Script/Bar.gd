extends VSplitContainer

#---------------------------------------------
# Function used to update the bar graph height
#---------------------------------------------
func Update_Bar_from_month(value,max_month):
	
	#----------------------------------
	#updating the time to pay off value
	#----------------------------------
	var time=month_to_year(value)
	if time["year"]==0:
		get_node("Bar_container/Time_label").text=str(time["month"])+" M"
	elif time["month"]!=0:
		get_node("Bar_container/Time_label").text=str(time["year"])+" Y "+str(time["month"])+" M"
	else:
		get_node("Bar_container/Time_label").text=str(time["year"])+" Y"

	#----------------------------------
	#updating the height of the bar
	#----------------------------------
	var spliting_fraction=value/max_month
	var spliter_size=self.get_size().y
	var min_bar_size=50
	var total_range=spliter_size-min_bar_size
	var new_spliter_value=spliting_fraction*total_range
	self.split_offset=spliter_size-new_spliter_value-min_bar_size
	
	#----------------------------------
	#updating the height of the bar
	#----------------------------------
	var text_position
	var bar_size=get_node("Bar_container/Bar").get_size()
	get_node("Bar_container/Bar/Name_label").set_clip_text(false)
	var text_size=get_node("Bar_container/Bar/Name_label").get_size()
	if(bar_size.x>bar_size.y or text_size.x<bar_size.x):# if bar widith is bigger than bar height
		get_node("Bar_container/Bar/Name_label").set_rotation_degrees(0)
		text_position=Vector2(0,(bar_size.y-text_size.y)/2)
		if(text_size.x<bar_size.x):#if text is smaller than the bar width
			text_position.x=(bar_size.x-text_size.x/2)/2
		else:
			text_size.x=bar_size.x
	else:
		get_node("Bar_container/Bar/Name_label").set_rotation_degrees(90.0)
		text_position=Vector2((bar_size.x+text_size.y)/2,0)
		if (text_size.x<bar_size.y):#if the text width is smaller than the height
			text_position.y=(bar_size.y-text_size.x/2)/2
			#pass
		else:
			text_size.x=bar_size.y
		print(text_position)
	#get_node("Bar_container/Bar/Name_label").set_clip_text(true)
	get_node("Bar_container/Bar/Name_label").set_position(text_position)
	get_node("Bar_container/Bar/Name_label").set_size(text_size)
		#affichacge vertical
	
	

#-------------------------------------------------------------------------------
# Function that transform a month in value into a dictionary of year/month value
#-------------------------------------------------------------------------------
func month_to_year(month):
	return {"month":month%12,"year":int(floor(month/12))}

#-------------------------------------------------------------------------------
# This function is used when creating a bar as it change the name
#-------------------------------------------------------------------------------
func init_bar(name):
	get_node("Bar_container/Bar/Name_label").text=name
	get_node("Bar_container/Time_label").text="N/A"

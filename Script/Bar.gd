extends VSplitContainer

#---------------------------------------------
# Function used to update the bar graph height
#---------------------------------------------
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

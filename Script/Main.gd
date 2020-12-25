extends Control
var list_entry=[]
var list_bar=[]
const LIST_ENTRY_NODE="Main_container/View_main/List/ScrollContainer/List_entry"
const LIST_BAR_NODE="Main_container/View_main/Bar_graph/Scroller_BG/BG"

func _ready():
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/Function_button").connect("item_selected",self,"_on_function_changed")
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/Quit_Button").connect("button_down",self,"_on_quit_pressed")
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/New entry").connect("button_down",self,"_on_New_entry_pressed")
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/File_button/File_Popup_Menu").connect("id_pressed",self,"_on_file_item_selected")
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/Apply").connect("button_down",self,"_on_apply_month_button_pressed")
# warning-ignore:return_value_discarded
	get_node("Main_container/Upper_Bar/CC/VC/HC_income/Next_month_value").connect("value_changed",self,"_on_Next_month_budget_value_changed")






#----------------------------------------------------------------
#CALLBACK FUNCTIONS
#----------------------------------------------------------------






#------------------------------------
# Function for quitting the software
#------------------------------------
func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_ESCAPE:
		get_tree().quit()
func _on_quit_pressed():
	get_tree().quit()


#------------------------------------
# Function for handling a new entry
#------------------------------------
func _on_New_entry_pressed():
	#handling what concern the
	Global.NUMBER_OF_ENTRY+=1
	Add_entry(preload("../scene/Entry.tscn").instance())
	Add_bar(preload("../scene/Bar.tscn").instance(),"")


#-------------------------------------------------
# handling file button (save/load/option/quit)
#-------------------------------------------------
func _on_file_item_selected(id):
	if id==0:
		New_page()
	elif id==1:
		get_node("load_dialog").popup()
	elif id==2:
		get_node("save_dialog").popup()
	elif id==3:
		#option menue not implemented yet
		pass
	elif id==4:
		_on_quit_pressed()
	else:
		push_warning("this id doesn't exist on the file button")


#-------------------------------------------------
# Function for handling save of the current state
#-------------------------------------------------
func _on_save_dialog_file_selected(path):
	var f = File.new()
	if f.open(path,File.WRITE)!=OK:
		push_warning("there was an error when opening profil: %s"%path)
		
	#---------------------
	#storing all variable
	#---------------------
	
	var save_dic={"current_monthly_budget": Global.MONTHLY_INCOME,
				"current_function": Global.USED_FUNCTION,
				"current_parameter_value": Global.PARAMETER,
				}
	f.store_line(to_json(save_dic))
	
	#---------------------
	#storing all the entry
	#---------------------
	
	for element in list_entry:
		f.store_line(to_json(element.create_save_dic()))
	f.close()


#-------------------------------------------------
# Function for handling load of the current state
#-------------------------------------------------
func _on_load_dialog_file_selected(path):
	Delete_all()
	var f = File.new()
	if f.open(path,File.READ)!=OK:
		push_warning("there was an error when opening profil: %s"%path)
		
	#---------------------
	#loading all variable
	#---------------------	
	
	var node_data = parse_json(f.get_line())
	
	Global.MONTHLY_INCOME=node_data["current_monthly_budget"]
	get_node("Main_container/Upper_Bar/CC/VC/HC_income/Next_month_value").value=Global.MONTHLY_INCOME
	Global.USED_FUNCTION=node_data["current_function"]
	get_node("Main_container/Upper_Bar/CC/VC/Function_button").select(Global.USED_FUNCTION)
	Global.PARAMETER=node_data["current_parameter_value"]
	get_node("Main_container/Middle_Bar/Parameter_slider").value=Global.PARAMETER
	
	#---------------------
	#storing all the entry
	#---------------------
	Global.NUMBER_OF_ENTRY=0
	while f.get_position() < f.get_len():
		node_data = parse_json(f.get_line())
		
		Global.NUMBER_OF_ENTRY+=1
		Add_entry(preload("../scene/Entry.tscn").instance(),node_data,true)
		Add_bar(preload("../scene/Bar.tscn").instance(),node_data["name"])
		
		
	f.close()
	Global.NUMBER_OF_ENTRY=len(list_entry)
	for i in range(Global.NUMBER_OF_ENTRY):
		for j in range(Global.NUMBER_OF_ENTRY):
			if list_entry[j].position==i+1:
				get_node(LIST_ENTRY_NODE).move_child(list_entry[j],i)
				break
				#get_node(LIST_BAR_NODE).move_child(list_bar[j],i)
				
	Update_entry_list()


#---------------------------------------------------------------
# Function for handling the need for sorting when change is detected
#-----------------------------------------------------------------
func _on_Next_month_budget_value_changed(value):
	Global.MONTHLY_INCOME=value
	if list_entry!=[] and Global.MONTHLY_INCOME!=0:
		Update_all()


#---------------------------------------
#used when the slider is updated
#---------------------------------------
func _on_Parameter_slider_value_changed(value):
	value=stepify(value,0.01)
	Global.PARAMETER=value
	get_node("Main_container/Middle_Bar/Parameter_label").text="Paramter : "+str(value)
	if list_entry!=[] and Global.MONTHLY_INCOME!=0:
		Update_all()

#---------------------------------------
#used when the function is updated
#---------------------------------------
func _on_function_changed(id):
	if id==0:
		Global.USED_FUNCTION=Global.LINEAR
		get_node("Main_container/Middle_Bar/Parameter_slider").min_value=0
		get_node("Main_container/Middle_Bar/Min_box").min_value=0
	elif id==1:
		get_node("Main_container/Middle_Bar/Parameter_slider").min_value=1
		get_node("Main_container/Middle_Bar/Min_box").min_value=1
		Global.USED_FUNCTION=Global.POLYNOMIAL
	elif id==2:
		get_node("Main_container/Middle_Bar/Parameter_slider").min_value=1
		get_node("Main_container/Middle_Bar/Min_box").min_value=1
		Global.USED_FUNCTION=Global.EXPONENTIAL
	else: 
		get_node("Main_container/Middle_Bar/Parameter_slider").min_value=1.01
		get_node("Main_container/Middle_Bar/Min_box").min_value=1.01
		Global.USED_FUNCTION=Global.LOGARITHMIC


#-------------------------------------------
# update the next month value request
#-------------------------------------------
func _on_apply_month_button_pressed():
	Update_for_next_month()


#-------------------------------------------------------------------------------------------
# Callback when the classement value of an entry have been changed and we need to sort them
#-------------------------------------------------------------------------------------------
func _on_sorting_needed(ref_entry):
	Sort_Enrtry_From_List(ref_entry)

#-------------------------------------------------------------------------
# Callback When we need to delete and entry from the delete entry button
#-------------------------------------------------------------------------
func _on_deleted_entry(position_node):
	for element in list_entry:# lock the element because value is changed and we don't want to emit signal
		element.lock()
	for i in range(0,Global.NUMBER_OF_ENTRY):
		if list_entry[i].position==position_node+1:#+1 because we look at the rank
			get_node(LIST_ENTRY_NODE).remove_child(list_entry[i])
			get_node(LIST_BAR_NODE).remove_child(list_bar[i])
			list_entry[i].queue_free()
			list_bar[i].queue_free()
			list_entry.remove(i)
			list_bar.remove(i)
			break
	for i in range(position_node,Global.NUMBER_OF_ENTRY-1):
		#print(i)
		get_node(LIST_ENTRY_NODE).get_child(i).get_node("Rank_Value").value=i+1
		get_node(LIST_ENTRY_NODE).get_child(i).position=i+1
	
	Global.NUMBER_OF_ENTRY-=1
	Update_all()
	for element in list_entry:# lock the element because value is changed and we don't want to emit signal
		element.unlock()


#-------------------------------------------------------------------------
# This two function handle the min/max box value being changed
#-------------------------------------------------------------------------
func _on_Min_box_value_changed(value):
	get_node("Main_container/Middle_Bar/Parameter_slider").set_min(value)
	get_node("Main_container/Middle_Bar/Max_box").set_min(value+0.01)
func _on_Max_box_value_changed(value):
	get_node("Main_container/Middle_Bar/Parameter_slider").set_max(value)
	get_node("Main_container/Middle_Bar/Min_box").set_max(value-0.01)





#----------------------------------------------------------------
#----------------------------------------------------------------
#----------------------------------------------------------------







#-------------------------------------------------
# delet all entry on screen for a new page
#-------------------------------------------------
func New_page():
	Delete_all()
	list_entry=[]
	Global.NUMBER_OF_ENTRY=0

#------------------------------------
# Function for adding an entry to the whole scene
#------------------------------------
func Add_entry(new_entry,node_data:Dictionary={},has_second_paramter:bool =false):
	if has_second_paramter:
		new_entry.load_from_dic(node_data)
	else:
		new_entry.Init_node(Global.NUMBER_OF_ENTRY)
	new_entry.connect("need_sort",self,"_on_sorting_needed")
	new_entry.connect("deleted_entry",self,"_on_deleted_entry")
	new_entry.connect("price_changed",self,"Update_all")
	list_entry.append(new_entry)
	get_node(LIST_ENTRY_NODE).add_child(new_entry)


#------------------------------------
# Function for adding a bar to the scene
#------------------------------------
func Add_bar(new_bar,name):
	list_bar.append(new_bar)
	get_node(LIST_BAR_NODE).add_child(new_bar)
	list_bar[-1].init_bar(name)


#----------------------------------------------------------------------
# Function for freeing and deleting all the entry and bar on the scenne
#----------------------------------------------------------------------
func Delete_all():
	for i in range(0,Global.NUMBER_OF_ENTRY):
		get_node(LIST_ENTRY_NODE).remove_child(list_entry[0])
		get_node(LIST_BAR_NODE).remove_child(list_bar[0])
		list_entry[0].queue_free()
		list_bar[0].queue_free()
		list_entry.remove(0)
		list_bar.remove(0)
	Global.NUMBER_OF_ENTRY=0

#-------------------------------------------------------------------------
# These are function that update the look of the bar graph and entry of list
#-------------------------------------------------------------------------
func Update_all():
	Update_entry_list()
	Update_bar_graph()
func Update_bar_graph():
	if Global.MONTHLY_INCOME==0:
		return
	var max_month=0
	for element in list_entry:
		max_month+=element.get_node("Estimated_Price").value-element.get_node("Current_Invested_Money").value	
	if max_month==0:
		return
	max_month=ceil(max_month/Global.MONTHLY_INCOME)
	var bar_list_value=Algorithm.Get_time_to_pay_off(list_entry)
	for i in range(Global.NUMBER_OF_ENTRY):
		list_bar[i].Update_Bar_from_month(bar_list_value[i],max_month)
	Sort_bar_From_Time()
func Update_entry_list():
	var Monthly_Addition_list=Algorithm.Get_next_month_budget(list_entry)
	for i in range(Global.NUMBER_OF_ENTRY):
		list_entry[i].get_node("Monthly_Addition").set_value(Monthly_Addition_list[i])

#-------------------------------------------------------------------------------------------------------
# update the next month value for the entry by adding the monthly adition to the current_invested money
#-------------------------------------------------------------------------------------------------------------
func Update_for_next_month():
	for element in list_entry:
		element.get_node("Current_Invested_Money").value+=element.get_node("Monthly_Addition").value
	Update_all()

#------------------------------------------------------------------------
# sort the children of the entry list according to the list_entry ranking
#------------------------------------------------------------------------
func Sort_Enrtry_From_List(entry_to_change):
	var there_is_next=true
	var new_index=entry_to_change.get_node("Rank_Value").value
	entry_to_change.update_position(new_index)
	while there_is_next:
		for i in range(Global.NUMBER_OF_ENTRY):
			if list_entry[i]!=entry_to_change and list_entry[i].get_node("Rank_Value").value==entry_to_change.get_node("Rank_Value").value:
					#change the position of the node with the same number to it's new number
					entry_to_change.get_parent().move_child(entry_to_change,new_index-1)
					#we change to the new selected entry
					entry_to_change=list_entry[i]
					#the new index is the one of the new entry
					new_index=entry_to_change.get_index()+1
					#the new entry change its index
					entry_to_change.update_position(new_index)
					break
			if i==Global.NUMBER_OF_ENTRY-1:
				there_is_next=false

#------------------------------------------------------------
# sort the children of the bar graph in order of paid of time
#------------------------------------------------------------
func Sort_bar_From_Time():
	var bar_list_value=Algorithm.Get_time_to_pay_off(list_entry)
	for i in range(Global.NUMBER_OF_ENTRY):
		bar_list_value[i]=[bar_list_value[i],i]
	bar_list_value.sort_custom(Algorithm, "First_Index_Comparator")
	for i in range(Global.NUMBER_OF_ENTRY):
		list_bar[bar_list_value[i][1]].get_parent().move_child(list_bar[bar_list_value[i][1]],i)





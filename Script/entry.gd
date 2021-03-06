extends HBoxContainer
signal need_sort(changed_position_entry)
signal deleted_entry(position)
signal price_changed()

var position=0
var is_reimbursed=1
var is_lock=false

#-------------------------------------------------------
# For initing a new entry node we need to give it a rank
#-------------------------------------------------------
func Init_node(rank):
	get_node("Rank_Value").value=rank
	position=rank




#-------------------------------------------------------
#Used when we need to update the rank
#-------------------------------------------------------
func update_position(rank):
	lock()
	get_node("Rank_Value").set_value(rank)
	unlock()
	position=rank




#-------------------------------------------------------
#When the classement value is changed we need to check 
#if this is a valid value and call for sorting all the entry
#-------------------------------------------------------
func _on_Rank_Value_value_changed(_value):
	if not is_lock:
		emit_signal("need_sort",self)





#-------------------------------------------------------
#Function used for saving an loading entry
#-------------------------------------------------------
func create_save_dic():
	var save_dic ={
		"Rank_Value":get_node("Rank_Value").value,
		"name":get_node("Name").text,
		"Estimated_Price":get_node("Estimated_Price").value,
		"Current_Invested_Money":get_node("Current_Invested_Money").value,
		"is_reimbursed":is_reimbursed
		}
	return save_dic
func load_from_dic(dic):
	get_node("Rank_Value").value=dic["Rank_Value"]
	position=dic["Rank_Value"]
	get_node("Name").text=dic["name"]
	get_node("Estimated_Price").value=dic["Estimated_Price"]
	get_node("Current_Invested_Money").value=dic["Current_Invested_Money"]
	is_reimbursed=dic["is_reimbursed"]
	

#-------------------------------------------------------
#Handling an entry being erased
#-------------------------------------------------------
func _on_Errase_Entry_Button_pressed():
	emit_signal("deleted_entry",position-1)

#-------------------------------------------------------
#for locking/unlocking the entry from emitting a need for sort
#-------------------------------------------------------
func lock():
	is_lock=true
func unlock():
	is_lock=false


func _on_Estimated_Price_value_changed(value):
	emit_signal("price_changed")

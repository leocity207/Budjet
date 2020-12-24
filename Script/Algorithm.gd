extends Node




#-------------------------------------------------------------------------------------------------------
#this function is used as a base for cumputing the number of month needed to pay of entries
#Arguments:
#     -list_entry: a list of node with the entry it is only used to get the price value of each entry
#
#return:
#     -time_month_list: the list that contain the time in month to reimburse all entries in the entry list
#--------------------------------------------------------------------------------------------------------
func Get_time_to_pay_off(list_entry):
	var time_month_list=[]
	var Current_invested_money_list=[]
	var is_paid_off_list=[]
	for i in range(Global.NUMBER_OF_ENTRY):
		time_month_list.append(1)
		Current_invested_money_list.append(list_entry[i].get_node("Current_Invested_Money").value)
		is_paid_off_list.append(1)
		
	while not All_paid_off(is_paid_off_list) and Global.MONTHLY_INCOME !=0:
		var next_month_budget=Compute_next_month_budget(list_entry,is_paid_off_list,Current_invested_money_list)
		for i in range(Global.NUMBER_OF_ENTRY):
			if is_paid_off_list[i]==1:
				Current_invested_money_list[i]+=next_month_budget[i]
				time_month_list[i]+=1
	return time_month_list




#-------------------------------------------------------------------------------------------------------
#this function is used for preparing data before they get computed for the next month budget 
#this function is esentialy used to update the list of entry
#Arguments:
#     -list_entry: a list of node with the entry it is only used to get the price value of each entry
#
#return:
#     -/////: the list from the Compute_next_month_budget function
#--------------------------------------------------------------------------------------------------------
func Get_next_month_budget(list_entry):
	var time_month_list=[]
	var Current_invested_money_list=[]
	var is_paid_off_list=[]
	for i in range(Global.NUMBER_OF_ENTRY):
		time_month_list.append(1)
		Current_invested_money_list.append(list_entry[i].get_node("Current_Invested_Money").value)
		is_paid_off_list.append(1)
	return Compute_next_month_budget(list_entry,is_paid_off_list,Current_invested_money_list)




#-------------------------------------------------------------------------------------------------------
#this function is used as a base for cumputing the next month budget
#Arguments:
#     -list_entry: a list of node with the entry it is only used to get the price value of each entry
#     -is_paid_off_list: a list that keep track wether an entry has been entirely paid or not
#
#return:
#     -next_month_budget_list: the list that contain the budget for next month
#--------------------------------------------------------------------------------------------------------
func Compute_next_month_budget(list_entry,is_paid_off_list,Current_invested_money_list):
	var next_month_budget_list=[]
	for _i in range(Global.NUMBER_OF_ENTRY):
		next_month_budget_list.append(0)
	var there_is_reste=true
	var rest=Global.MONTHLY_INCOME
	var leftover=Global.MONTHLY_INCOME
	while there_is_reste==true and not(All_paid_off(is_paid_off_list)):
		var part=compute_part(list_entry,is_paid_off_list)
		for i in range(len(part)):
			if is_paid_off_list[i]==1:
				var update_value=floor(part[i]*rest*100)/100
				leftover-=update_value
				next_month_budget_list[i]+=update_value
		if  leftover>=0.01:
			Give_leftover(leftover,list_entry,is_paid_off_list,next_month_budget_list)
		var temp=Correct_overflow(list_entry,Current_invested_money_list,next_month_budget_list,is_paid_off_list)
		rest=temp[0]
		leftover+=temp[0]
		there_is_reste=temp[1]
				
			
	return next_month_budget_list




#-------------------------------------------------------------------------------------------------------
#correct the overflow comming in the next_month_money_list list
#Arguments:
#     -list_entry: a list of node with the entry it is only used to get the price value of each entry
#     -is_paid_off_list: a list that keep track wether an entry has been entirely paid or not
#     -next_month_money_list: the list for the next month budget, this list will be modified
#     -Current_invested_money_list: the list that contain how much each entry have been paid off yet
#
#return:
#     -rest: what is left of this month budget that need to be budgeted again
#     -is_there_rest: boolean that is true if an overpayment occure
#--------------------------------------------------------------------------------------------------------
func Correct_overflow(list_entry,Current_invested_money_list,next_month_money_list,is_paid_off_list):
	var reste=0
	var local_reste=0
	var is_there_rest=false
	for i in range(Global.NUMBER_OF_ENTRY):
		if list_entry[i].get_node("Estimated_Price").value<Current_invested_money_list[i]+next_month_money_list[i] and is_paid_off_list[i]==1:
			is_paid_off_list[i]=0
			local_reste=Current_invested_money_list[i]+next_month_money_list[i]-list_entry[i].get_node("Estimated_Price").value
			next_month_money_list[i]=list_entry[i].get_node("Estimated_Price").value-Current_invested_money_list[i]
			reste+=local_reste
			is_there_rest=true
	return [reste,is_there_rest]




#-------------------------------------------------------------------------------------------------------
#compute the fraction of which the entry will recieve from the budget this month
#Arguments:
#     -list_entry: a list of node with the entry it is only used to get the classement value of each entry
#     -is_paid_off_list: a list that keep track wether an entry has been entirely paid or not
#
#return:
#     -part: the fraction of the current money for each entry
#--------------------------------------------------------------------------------------------------------
func compute_part(list_entry,is_paid_off_list):
	var Next_month_part=[]
	var total=0
	
	#------------------------------------------
	#first we compute the new part
	#------------------------------------------
	if Global.USED_FUNCTION==Global.LINEAR:
		for i in range(Global.NUMBER_OF_ENTRY):
			total+=is_paid_off_list[i]*(Global.NUMBER_OF_ENTRY-list_entry[i].position+1+Global.PARAMETER)
		for i in range(Global.NUMBER_OF_ENTRY):
			Next_month_part.append(is_paid_off_list[i] * (Global.NUMBER_OF_ENTRY-list_entry[i].position+1+Global.PARAMETER) / total)
	if Global.USED_FUNCTION==Global.POLYNOMIAL:
		for i in range(Global.NUMBER_OF_ENTRY):
			total+=is_paid_off_list[i]*pow(Global.NUMBER_OF_ENTRY-list_entry[i].position+1, Global.PARAMETER)
		for i in range(Global.NUMBER_OF_ENTRY):
			Next_month_part.append(is_paid_off_list[i]*pow(Global.NUMBER_OF_ENTRY-list_entry[i].position+1, Global.PARAMETER) / total)
	if Global.USED_FUNCTION==Global.EXPONENTIAL:
		for i in range(Global.NUMBER_OF_ENTRY):
			total+=is_paid_off_list[i]*exp((Global.NUMBER_OF_ENTRY-list_entry[i].position+1)*log(Global.PARAMETER))
		for i in range(Global.NUMBER_OF_ENTRY):
			Next_month_part.append(is_paid_off_list[i]*exp((Global.NUMBER_OF_ENTRY-list_entry[i].position+1)*log(Global.PARAMETER)) / total)	
	if Global.USED_FUNCTION==Global.LOGARITHMIC:
		for i in range(Global.NUMBER_OF_ENTRY):
			total+=is_paid_off_list[i]*log((Global.NUMBER_OF_ENTRY-list_entry[i].position+1)*Global.PARAMETER)
		for i in range(Global.NUMBER_OF_ENTRY):
			Next_month_part.append(is_paid_off_list[i]*log((Global.NUMBER_OF_ENTRY-list_entry[i].position+1)*Global.PARAMETER) / total)
	return Next_month_part




#-------------------------------------------------------------------------------------------------------
#function that return true if the is_paid_of_list is full of 0(all entry have been paid off)
#--------------------------------------------------------------------------------------------------------	
func All_paid_off(is_paid_off_list):
	for value in is_paid_off_list:
		if value==1:
			return false
	return true




#-------------------------------------------------------------------------------------------------------
#function used to give the small leftover when rounding to the highest in the classement
#Arguments:
#		-leftover: the leftover value that need to be allocated
#		-list_entry: the list of entry object (used to retrieve the clasment position)
#		-is_paid_off_list: list of 0 (paid off)and 1 (paid off) for the entry ellement
#		-next_month_budget_list: the next month budget list corresponding to each entry
#--------------------------------------------------------------------------------------------------------	
func Give_leftover(leftover,list_entry,is_paid_off_list,next_month_budget_list):
	var leftover_not_given=true
	var classement_pos=1
	while leftover_not_given:
		for i in range(Global.NUMBER_OF_ENTRY):
			if list_entry[i].position==classement_pos:
				if is_paid_off_list[i]==0:
					classement_pos+=1
					break
				else:
					next_month_budget_list[i]+=leftover
					leftover_not_given=false
					break



#-------------------------------------------------------------------------------------------------------
#function used to comapare first index of an array (the purpose of this function is for sorting)
#------------------------------------------------------------------------------------------------------
func First_Index_Comparator(a,b):
	if a[0]<b[0]:
		return true
	return false

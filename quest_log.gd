extends Control

# Item selections
const Colors : Array[Color] = [
	Color.WEB_GRAY, Color.YELLOW, Color.GREEN, Color.BLUE,
	Color.REBECCA_PURPLE, Color.DARK_RED, Color.ORANGE ]
const Rarities : Array[String] = [
	"Common", "Uncommon", "Rare", "Epic", "Legendary", "Artifact", "Celestial"]
const Categories : Array[String] = [
	"Armor", "Food", "Storage", "Tool", "Weapon", "System" ]
const DamageTypes : Array[String] = ["Blunt", "Energy", "Piercing", "Slashing"]

# required item
var reqItmSel:Array[int]=[0,0,0]
var reqItmDmg:int=0
var reqItmDef:int=0
var reqItmSz:int=0
var reqItmDesc:String=""

# reward item
var rewItmSel:Array[int]=[0,0,0]
var rewItmDmg:int=0
var rewItmDef:int=0
var rewItmSz:int=0
var rewItmDesc:String=""

# This enumeration has the same values as the $optTasktype.items
enum Tasktype { Battle=0, Relocate=1 }

# internal variables
var _book_file : String = "user://logbook.dat"
var _file_mode : int = 0
var _activeIdx : int = -1

# the task being edited
var ActiveTask : Dictionary
var taskName : String = ""
var taskSummary : String = ""
var taskType : int = 0
var taskRequiredItem : Dictionary = {}
var taskRewardItem : Dictionary = {}
var taskRewardXP : int = 0
var taskRewardCash : int = 0
var taskDescription : String = ""

# interface items
@export var Logbook : Array[Dictionary] = []
@export var listTasklist : ItemList
@export var leTitle : LineEdit
@export var leBrief : LineEdit
@export var optTasktype : OptionButton
@export var leXP : LineEdit
@export var leCash : LineEdit
@export var mdDescription : MarkdownLabel
@export var teDescription : TextEdit

var NewTask : Dictionary = {
	"Name":"Move to point.",
	"Summary":"Use input to move.",
	"Description":"Use the input to move your character to the designated position.",
	"Tasktype":Tasktype.Relocate,
	"RewardXP":1,
	"RewardCash":0,
	"RewardItem":null,
	"RequiredItem":null,
	"Chained":false,
	"PreviousChainTask":null,
	"NextChainTask":null,
	"StartPos":var_to_str( Vector3.ZERO ),
	"EndPos":var_to_str( Vector3.ONE ),
	"Defend":null,
	"Destroy":null
}

func _notification(what: int) -> void:
	# autosave on close of application
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_questbook()

func _on_btn_save_logbook_pressed() -> void:
	save_questbook()

func _on_btn_load_logbook_pressed() -> void:
	load_questbook()

func _on_btn_add_task_pressed() -> void:
	# copy template dictionary
	ActiveTask = NewTask.duplicate()
	# use the logbook size() as the index for the new task
	Logbook.push_back(ActiveTask)
	listTasklist.add_item( ActiveTask["Name"] )
	# store the active index
	_activeIdx = listTasklist.get_child_count()
	# select the new item
	listTasklist.select(_activeIdx)

func _on_btn_del_task_pressed() -> void:
	# clear the input fields
	leTitle.text = ""
	leBrief.text = ""
	optTasktype.select( 0 )
	teDescription.text = ""
	# drop the data from memory
	listTasklist.remove_item( _activeIdx )
	Logbook.erase( _activeIdx )
	ActiveTask.clear()
	_activeIdx = -1

func _on_itemlist_tasklist_item_selected(index: int) -> void:
	_activeIdx = index
	var _name : String = listTasklist.get_item_text(_activeIdx)
	ActiveTask = Logbook[_activeIdx]
	# need to change active task to selection from logbook
	leTitle.text = ActiveTask["Name"]
	leBrief.text = ActiveTask["Summary"]
	optTasktype.select( ActiveTask["Tasktype"] )
	leXP.text = ActiveTask["RewardXP"] 
	leCash.text = String(ActiveTask["RewardCash"])
	teDescription.text = ActiveTask["Description"]

func _on_itemlist_tasklist_empty_clicked(_at_position: Vector2, _mouse_button_index: int) -> void:
	_activeIdx = -1

func _on_le_title_text_changed(new_text):
	taskName = new_text

func _on_le_title_text_submitted(new_text):
	taskName = new_text
	ActiveTask["Name"] = taskName

func _on_le_brief_text_changed(new_text):
	taskSummary = new_text

func _on_le_brief_text_submitted(new_text):
	taskSummary = new_text
	ActiveTask["Summary"] = taskSummary

func _on_opt_tasktype_item_selected(index):
	taskType = index

func _on_btn_req_item_pressed():
	pass # Replace with function body.

func _on_btn_reward_item_pressed():
	pass # Replace with function body.

func _on_le_xp_text_changed(new_text):
	taskRewardXP = float(new_text)

func _on_le_xp_text_submitted(new_text):
	taskRewardXP = float(new_text)
	ActiveTask["RewardXP"] = taskRewardXP

func _on_le_cash_text_changed(new_text):
	taskRewardCash = float(new_text)

func _on_le_cash_text_submitted(new_text):
	taskRewardCash = float(new_text)
	ActiveTask["RewardCash"] = taskRewardCash

func _on_te_description_text_changed() -> void:
	taskDescription = teDescription.text

func _on_te_description_caret_changed():
	taskDescription = teDescription.text

func _on_te_description_text_set():
	taskDescription = teDescription.text
	mdDescription.markdown_text = taskDescription

func _on_btn_task_update_pressed():
	# update UI
	listTasklist.set_item_text(_activeIdx, taskName)
	mdDescription.markdown_text = taskDescription
	# update data model
	ActiveTask["Name"] = taskName
	ActiveTask["Summary"] = taskSummary
	ActiveTask["Tasktype"] = taskType
	ActiveTask["Description"] = taskDescription
	# update collection
	Logbook[_activeIdx] = ActiveTask

func _on_btn_task_reset_pressed():
	# get the stored values
	ActiveTask = Logbook[_activeIdx]
	# copy data back to input fields
	leTitle.text = ActiveTask["Name"]
	leBrief.text = ActiveTask["Summary"]
	optTasktype.select( ActiveTask["Tasktype"] )
	teDescription.text = ActiveTask["Description"]

func load_questbook()->void:
	# open directory and read questbook
	var dir := DirAccess.open("user://")
	if dir.file_exists(_book_file):
		_file_mode = FileAccess.READ_WRITE
	else:
		_file_mode = FileAccess.WRITE_READ
	var fIn := FileAccess.open(_book_file, _file_mode)
	while fIn.get_position() < fIn.get_length():
	# Read data 
	# if there are multiple root dictionairies the last one will be in memory
		var vIn = fIn.get_var() as Array
		Logbook = vIn.duplicate()
		# copy quests to listitem in interface
		listTasklist.clear()
		for _q in Logbook:
			listTasklist.add_item(_q["Name"])

func save_questbook()->void:
	# this overwrites the old file every time
	_file_mode = FileAccess.WRITE
	var fout := FileAccess.open(_book_file, _file_mode)
	fout.store_var( Logbook ) # this is binary storage
	fout.close()

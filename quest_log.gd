extends Control

# This enumerations has the same values as the $optTasktype.items

enum Tasktype { Battle=0, Relocate=1 }

var _book_file : String = "user://logbook.json"
var _file_mode : int = 0
var _activeIdx : int = -1
var ActiveTask : Dictionary
var taskName : String = ""
var taskSummary : String = ""
var taskType : int = 0
var taskDescription : String = ""

#@export var LogbookName : String = "logbook.json"
@export var Logbook : Dictionary = {}
@export var listTasklist : ItemList
@export var leTitle : LineEdit
@export var leBrief : LineEdit
@export var optTasktype : OptionButton
@export var mdDescription : MarkdownLabel
@export var teDescription : TextEdit

var NewTask : Dictionary = {
	"Name":"Move to point.",
	"Summary":"Use input to move.",
	"Description":"Use the input to move your character to the designated position.",
	"Tasktype":Tasktype.Relocate,
	"RewardXP":1,
	"Chained":false,
	"PreviousChainTask":null,
	"NextChainTask":null,
	"StartPos":var_to_str( Vector3.ZERO ),
	"EndPos":var_to_str( Vector3.ONE ),
	"Defend":null,
	"Destroy":null
}

func _notification(what: int) -> void:
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
	Logbook[ Logbook.size() ] = ActiveTask
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
	listTasklist.remove_item(_activeIdx)
	ActiveTask.clear()
	_activeIdx = -1

func _on_itemlist_tasklist_item_selected(index: int) -> void:
	ActiveTask = Logbook.get(index)
	# need to change active task to selection from logbook
	leTitle.text = ActiveTask["Name"]
	leBrief.text = ActiveTask["Summary"]
	optTasktype.select( ActiveTask["Tasktype"] )
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

func _on_te_description_text_changed() -> void:
	taskDescription = teDescription.text

func _on_te_description_caret_changed():
	taskDescription = teDescription.text

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

func exit_app()->void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func load_questbook()->void:
	# open directory and read questbook
	var dir := DirAccess.open("user://")
	if dir.file_exists(_book_file):
		_file_mode = FileAccess.READ_WRITE
	else:
		_file_mode = FileAccess.WRITE_READ
	var fin := FileAccess.open(_book_file, _file_mode)
	print_debug(fin, Logbook)

func save_questbook()->void:
	_file_mode = FileAccess.WRITE
	var fout := FileAccess.open(_book_file, _file_mode)
	#var _logbook = JSON.stringify(Logbook)
	for _quest in Logbook as Dictionary:
		var _out = JSON.stringify(_quest)
		fout.store_string(_out)
	fout.close()

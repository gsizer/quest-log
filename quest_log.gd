extends Control

# This enumerations has the same values as the $optTasktype.items

enum Tasktype { Battle=0, Relocate=1, Transport=2 }

var _book : String = "user://"+LogbookName
var _mode : int = 0

@export var LogbookName : String = "logbook.json"
@export var Logbook : Dictionary = {}
@export var ActiveTask : Dictionary
@export var listTasklist : ItemList
@export var leTitle : LineEdit
@export var leBrief : LineEdit
@export var optTasktype : OptionButton
@export var mdDescription : MarkdownLabel
@export var teDescription : TextEdit

var NewTask : Dictionary = {
	"Name":"Movement",
	"Brief":"Use the input to move.",
	"Description":"Use the input to move your character to the designated position.",
	"Tasktype":Tasktype.Relocate,
	"RewardXP":1,
	"Chained":false,
	"PreviousChainTask":null,
	"NextChainTask":null,
	"StartPos":var_to_str( Vector3.ZERO ),
	"EndPos":var_to_str( Vector3(10.0, 0.0, 10.0) ),
	"Defend":null,
	"Destroy":null
}

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		pass

func _on_btn_save_logbook_pressed() -> void:
	save_questbook()

func _on_btn_load_logbook_pressed() -> void:
	load_questbook()

func _on_btn_add_task_pressed() -> void:
	ActiveTask = NewTask.duplicate()
	listTasklist.add_item(ActiveTask.get("Name"))

func _on_btn_del_task_pressed() -> void:
	pass # Replace with function body.

func _on_btn_dup_task_pressed() -> void:
	pass # Replace with function body.

func _on_itemlist_tasklist_item_selected(index: int) -> void:
	pass # Replace with function body.

func _on_itemlist_tasklist_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	pass # Replace with function body.

func _on_le_title_text_changed(new_text):
	ActiveTask.get_or_add("Name", new_text)

func _on_le_brief_text_changed(new_text):
	ActiveTask.get_or_add("Brief", new_text)

func _on_opt_tasktype_item_selected(index):
	ActiveTask.get_or_add("Tasktype", index)

func _on_te_description_text_changed() -> void:
	mdDescription.markdown_text = teDescription.text

func exit_app()->void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func load_questbook()->void:
	# open directory and read questbook
	var dir := DirAccess.open("user://")
	if dir.file_exists(_book):
		_mode = FileAccess.READ_WRITE
	else:
		_mode = FileAccess.WRITE_READ
	var fin := FileAccess.open(_book, _mode)
	print_debug(fin, Logbook)

func save_questbook()->void:
	_mode = FileAccess.WRITE
	var fout := FileAccess.open(_book, _mode)
	fout.store_var(Logbook)

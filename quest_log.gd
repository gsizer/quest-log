extends Control

# This enumerations has the same values as the $optTasktype.items

enum Tasktype { Battle=0, Relocate=1, Transport=2 }

var LogbookName : String = "logbook.json"
var Logbook : Dictionary = {}
var NewTask : Dictionary = {
	"Name":"New Task",
	"Brief":"A summary of the task.",
	"Description":"The complete task flavor text.",
	"Tasktype":Tasktype.Relocate,
	"RewardXP":100,
	"Chained":false,
	"PreviousChainTask":Object.new(),
	"NextChainTask":Object.new(),
	"StartPos":var_to_str(Vector3.ZERO),
	"EndPos":var_to_str(Vector3.ONE),
	"Defend":Object.new(),
	"Destroy":Object.new()
}

@export var ActiveTask : Dictionary
@export var listTasklist : ItemList
@export var leTitle : LineEdit
@export var leBrief : LineEdit
@export var optTasktype : OptionButton
@export var teDescription : TextEdit

func _notification(what: int) -> void:
# write data to disk and close files
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		pass

func _on_btn_save_logbook_pressed() -> void:
	pass # Replace with function body.

func _on_btn_load_logbook_pressed() -> void:
	pass # Replace with function body.

func _on_btn_add_task_pressed() -> void:
	pass # Replace with function body.

func _on_btn_del_task_pressed() -> void:
	pass # Replace with function body.

func _on_btn_dup_task_pressed() -> void:
	pass # Replace with function body.

func _on_itemlist_tasklist_item_selected(index: int) -> void:
	pass # Replace with function body.

func _on_itemlist_tasklist_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	pass # Replace with function body.

func _on_te_description_text_changed() -> void:
	pass # Replace with function body.

func _ready() -> void:
	ActiveTask = NewTask.duplicate()
	# Load Taskbook
	# Populate TaskList

func exit_app()->void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)

func load_taskbook()->void:
	pass

func save_taskbook()->void:
	pass

extends Control

@export var CountSpin : SpinBox
@export var DieList : OptionButton
@export var ResultList: ItemList
var _vscroll : VScrollBar

enum Dice { D4=4, D6=6, D8=8, D10=10, D12=12, D20=20, D100=100 }

var ResultString : String = "{i}:{r}"
var RollString : String = "Rolled {C}D{F} = {S} | Results: {R}"
@export var LastRoll : Dictionary = { "Count"=0, "Die"=Dice.D4, "Results"=_lastResults, "Total"=0 }

var _count : int = 1
var _face := Dice.D4
var _lastResults : Array[int] = []
var _total : int = 0

func _ready():
	_lastResults.clear()
	ResultList.clear()
	_vscroll = ResultList.get_v_scroll_bar()
	DieList.add_item("D4")
	DieList.add_item("D6")
	DieList.add_item("D8")
	DieList.add_item("D10")
	DieList.add_item("D12")
	DieList.add_item("D20")
	DieList.add_item("D100")
	ResultList.add_item("Click a result to copy it.")

func Roll( Count:int, Die:int) -> Array:
	_lastResults.clear()
	for d in Count:
		var result : int = randi_range( 1, Die)
		_lastResults.append( result )
	print_debug(_lastResults)
	return _lastResults

func _on_count_spin_value_changed(value):
	_count = value
	print_debug(_count)

func _on_btn_roll_pressed():
	var resultArray = Roll(_count, _face)
	_total=0
	for r in resultArray: _total += r
	var thisRoll = LastRoll
	thisRoll["Count"]=_count
	thisRoll["Die"]=_face
	thisRoll["Results"]=resultArray
	thisRoll["Total"]=_total
	ResultList.add_item(RollString.format({"C":_count, "F":_face, "S":_total, "R":resultArray}))
	_vscroll.set_value_no_signal(_vscroll.max_value)
	LastRoll = { "Count":_count, "Die":_face, "Result":_total}
	print_debug(thisRoll)

func _on_die_option_item_selected(index):
	match index:
		0: _face=Dice.D4
		1: _face=Dice.D6
		2: _face=Dice.D8
		3: _face=Dice.D10
		4: _face=Dice.D12
		5: _face=Dice.D20
		6: _face=Dice.D100
	print_debug(_face)

func _on_result_list_item_selected(index):
	var rstring : String = ResultList.get_item_text(index)
	DisplayServer.clipboard_set(rstring)

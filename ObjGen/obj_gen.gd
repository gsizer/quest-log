extends Control

const defaultText := "Choose Option"

const Colors : Array[Color] = [
	Color.WEB_GRAY, Color.YELLOW, Color.GREEN, Color.BLUE,
	Color.REBECCA_PURPLE, Color.DARK_RED, Color.ORANGE ]

const Rarities : Array[String] = [
	"Common", "Uncommon", "Rare", "Epic", "Legendary",
	"Artifact", "Celestial"]

const Categories : Array[String] = [
	"Armor", "Food", "Storage", "Tool", "Weapon", "System" ]

const DamageTypes : Array[String] = [
	"Blunt", "Energy", "Piercing", "Slashing"]

var FormatString : String = "[b]A [color={Co}]{R}[/color] {Ca} of {Dt}[/b]."
var DescriptionString : String = ""
var _selected : Array[int] = [0,0,0]

@export var lineItemName : LineEdit
var itemName : String
@export var menuRarities : MenuButton
var btnRare : PopupMenu
@export var menuCategories : MenuButton
var btnCat : PopupMenu
@export var menuDamageTypes : MenuButton
var btnDmgType : PopupMenu
@export var mdDescription : MarkdownLabel

func update_description():
	var r : String = Rarities[_selected[0]]
	var ca : String = Categories[_selected[1]]
	var co : Color = Colors[_selected[0]]
	var dt : String = DamageTypes[_selected[2]]
	DescriptionString = FormatString.format( { "R":r, "Ca":ca, "Co":co.to_html(), "Dt":dt } )
	print_debug("Description:", DescriptionString)
	mdDescription.markdown_text = DescriptionString

func _on_le_item_name_text_changed(new_text:String):
	itemName = new_text.to_snake_case()

func _on_btn_rare_select(id:int)->void:
	print_debug("Rarity:", id, ":", Rarities[id])
	menuRarities.text=Rarities[id]
	_selected[0]=id
	update_description()

func _on_btn_cat_select(id:int)->void:
	print_debug("Category:", id, ":", Categories[id])
	menuCategories.text=Categories[id]
	_selected[1]=id
	update_description()

func _on_btn_dmgType_select(id:int)->void:
	print_debug("DamageType:", id, ":", DamageTypes[id])
	menuDamageTypes.text=DamageTypes[id]
	_selected[2]=id
	update_description()

func _on_btn_random_pressed():
	print_debug("btnRandom")
	_on_btn_rare_select( randi_range(0, Rarities.size()-1) )
	_on_btn_cat_select( randi_range(0, Categories.size()-1) )
	_on_btn_dmgType_select( randi_range(0, DamageTypes.size()-1) )

func _on_btn_reset_pressed():
	print_debug("btnReset")
	lineItemName.clear()
	menuRarities.text = defaultText
	menuCategories.text = defaultText
	menuDamageTypes.text = defaultText
	mdDescription.markdown_text = ""

func _on_btn_copy_pressed():
	var clipboard : String = itemName+":"+DescriptionString
	print_debug("Copied String to Clipboard:", clipboard)
	DisplayServer.clipboard_set(clipboard)

func _ready():
	print_debug("Ready")
	btnRare = menuRarities.get_popup()
	btnRare.connect("id_pressed", _on_btn_rare_select)
	for rarity in Rarities:
		btnRare.add_item(rarity)
	btnCat = menuCategories.get_popup()
	btnCat.connect("id_pressed", _on_btn_cat_select)
	for category in Categories:
		btnCat.add_item(category)
	btnDmgType = menuDamageTypes.get_popup()
	btnDmgType.connect("id_pressed", _on_btn_dmgType_select)
	for dmgType in DamageTypes:
		btnDmgType.add_item(dmgType)

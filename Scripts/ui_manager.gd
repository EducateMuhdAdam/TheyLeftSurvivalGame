extends CanvasLayer

var watertest = preload("res://Scenes/building_ui/water_filter_ui.tscn")

@onready var inventory: Control = $Inventory
@onready var build_menu: Control = $BuildMenu
@onready var hud: Control = $HUD
@onready var ui_container: HBoxContainer = $CenterContainer/UIContainer

var modeNum: int = 0
var build_mode: bool = true
var inventory_mode: bool = false

func _ready() -> void:
	var node = watertest.instantiate()
	share_ui(node.get_panel())
	

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	if event.is_action_pressed("build"):
		toggle_build_mode()

func toggle_inventory() -> void:
	if !inventory_mode:
		set_inventory(true)
		set_build_menu(false)
	else:
		set_inventory(false)

func toggle_build_mode() -> void:
	if !build_mode:
		set_build_menu(true)
		set_inventory(false)
	else:
		set_build_menu(false)

func set_inventory(is_on: bool) -> void:
	if is_on:
		inventory_mode = true
		EventBus.toggle_inventory.emit(true)
	else:
		inventory_mode = false
		EventBus.toggle_inventory.emit(false)

func set_build_menu(is_on: bool) -> void:
	if is_on:
		build_mode = true
		EventBus.toggle_build_mode.emit(true)
	else:
		build_mode = false
		EventBus.toggle_build_mode.emit(false)

func share_ui(new_node: Node) -> void:
	inventory.change_column_num(5)
	print(new_node)
	new_node.reparent(ui_container)

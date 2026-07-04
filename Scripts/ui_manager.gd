extends CanvasLayer

@onready var inventory: Control = $Inventory
@onready var build_menu: Control = $BuildMenu
@onready var hud: Control = $HUD

@onready var ui_container: HBoxContainer = $CenterContainer/UIContainer

var modeNum: int = 0
var build_mode: bool = true
var inventory_mode: bool = false

func _ready() -> void:
	inventory.get_panel().reparent(ui_container)
	EventBus.shared_ui.connect(open_shared_mode)
	EventBus.toggle_build_mode.connect(set_build_mode)
	

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

func set_build_mode(active: bool) -> void:
	build_mode = active

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
		EventBus.toggle_placement_mode.emit(false)
	else:
		inventory_mode = false
		EventBus.toggle_inventory.emit(false)

func set_build_menu(is_on: bool) -> void:
	if is_on:
		EventBus.toggle_build_mode.emit(true)
		EventBus.toggle_placement_mode.emit(false)
	else:
		EventBus.toggle_build_mode.emit(false)

func open_shared_mode(node: PanelContainer, building: Node) -> void:
	inventory.toggle_shared_mode(true)
	ui_container.add_child(node)
	toggle_inventory()

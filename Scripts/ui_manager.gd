extends CanvasLayer

var player: CharacterBody2D
@onready var inventory: Control = $Inventory
@onready var build_menu: Control = $BuildMenu
@onready var hud: Control = $HUD

@onready var ui_container: HBoxContainer = $CenterContainer/UIContainer
@onready var mode_display: Control = $ModeDisplay
@onready var pause_menu: Control = $PauseMenu
@onready var color_rect: ColorRect = $ColorRect

@export var main: Node2D
var messagePanelScene = preload("res://Scenes/game_ui/message_panel.tscn")
var modeSignals: Array[Signal] = [EventBus.toggle_build_mode, EventBus.toggle_destroy_mode, EventBus.toggle_placement_mode, EventBus.toggle_inventory]
var modeNum: int = 0
var single_panel: PanelContainer
var build_mode: bool = false
var destroy_mode: bool = false
var inventory_mode: bool = false
var placement_mode: bool = false

func _ready() -> void:
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player = await Game.get_player()
	pause_menu.main = main
	inventory.get_panel().reparent(ui_container)
	EventBus.single_ui.connect(open_single_mode)
	EventBus.shared_ui.connect(open_shared_mode)
	EventBus.toggle_build_mode.connect(set_build_mode)
	EventBus.toggle_inventory.connect(set_inventory_mode)
	EventBus.toggle_destroy_mode.connect(set_destroy_mode)
	EventBus.toggle_placement_mode.connect(set_placement_mode)
	EventBus.open_message.connect(show_message)


func activate_one_mode(exception: Variant):
	var signals = modeSignals.duplicate()
	if exception is Signal:
		signals.erase(exception)
		exception.emit(true)
	for s in signals:
		s.emit(false)
	if !exception:
		EventBus.mode_display.emit(GlobalEnum.BuildMode.OFF)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("R"):
		print(player.global_position)
	if event.is_action_pressed("escape"):
		handle_escape()
	if !main.paused:
		return
	if event.is_action_pressed("inventory"):
		toggle_inventory()
	if event.is_action_pressed("build"):
		toggle_build_mode()
	if event.is_action_pressed("destroy"):
		toggle_destroy_mode()
	

func handle_escape() -> void:
	if build_mode or inventory_mode or destroy_mode or placement_mode:
		activate_one_mode(null)
	else:
		main.handle_pause()

func toggle_inventory() -> void:
	if !inventory_mode:
		set_inventory(true)
	else:
		set_inventory(false)

func toggle_destroy_mode() -> void:
	if !destroy_mode:
		set_destroy(true)
	else:
		set_destroy(false)

func set_build_mode(active: bool) -> void:
	build_mode = active
	if active:
		EventBus.mode_display.emit(GlobalEnum.BuildMode.PLACE)

func set_inventory_mode(active: bool) -> void:
	inventory_mode = active
	if active:
		EventBus.mode_display.emit(GlobalEnum.BuildMode.OFF)

func set_destroy_mode(active: bool) -> void:
	destroy_mode = active
	if active:
		EventBus.mode_display.emit(GlobalEnum.BuildMode.DESTROY)

func set_placement_mode(active: bool) -> void:
	placement_mode = active

func toggle_build_mode() -> void:
	if !build_mode:
		set_build_menu(true)
	else:
		set_build_menu(false)

func set_destroy(is_on: bool) -> void:
	if is_on:
		activate_one_mode(EventBus.toggle_destroy_mode)
	else:
		activate_one_mode(null)

func set_inventory(is_on: bool) -> void:
	if is_on:
		activate_one_mode(EventBus.toggle_inventory)
	else:
		if not(inventory.get_panel() in ui_container.get_children()):
			ui_container.add_child(inventory.get_panel())
		activate_one_mode(null)

func set_build_menu(is_on: bool) -> void:
	if is_on:
		activate_one_mode(EventBus.toggle_build_mode)
	else:
		activate_one_mode(null)

func open_shared_mode(node: PanelContainer, building: Node) -> void:
	inventory.toggle_shared_mode(true)
	ui_container.add_child(node)
	toggle_inventory()

func open_single_mode(node: PanelContainer) -> void:
	if inventory.get_panel() in ui_container.get_children():
		ui_container.remove_child(inventory.get_panel())
	ui_container.add_child(node)
	single_panel = node
	toggle_inventory()

func show_pause_menu(show: bool) -> void:
	if show:
		pause_menu.show()
	else:
		pause_menu.hide()

func show_message(messageData: MessageData) -> void:
	var msgPanel = messagePanelScene.instantiate()
	msgPanel.messageData = messageData
	EventBus.single_ui.emit(msgPanel)

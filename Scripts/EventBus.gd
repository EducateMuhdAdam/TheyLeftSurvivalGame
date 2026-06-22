extends Node

signal change_building(building_data: BuildingData)
signal toggle_build_mode(mode: bool)
signal toggle_inventory(node: bool)
signal add_item(itemData: ItemData)
signal shared_ui(panel: PanelContainer, parent: Node)

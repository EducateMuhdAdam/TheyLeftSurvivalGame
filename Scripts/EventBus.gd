extends Node

signal change_building(building_data: BuildingData)
signal toggle_build_mode(mode: bool)
signal toggle_placement_mode(mode: bool)
signal toggle_inventory(node: bool)
signal shared_ui(panel: PanelContainer, parent: Node)

signal add_item(itemData: ItemData)
signal add_multiple_item(itemData: ItemData, quantity: int)
signal erase_item(slotID: int)
signal swap_item(slotID_1: int, slotID_2)
signal remove_item(slotID: int)

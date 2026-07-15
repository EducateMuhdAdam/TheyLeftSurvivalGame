extends Node

signal change_building(building_data: BuildingData)
signal toggle_build_mode(mode: bool)
signal toggle_placement_mode(mode: bool)
signal toggle_destroy_mode(mode: bool)
signal toggle_inventory(mode: bool)
signal mode_display(modeType: GlobalEnum.BuildMode)
signal shared_ui(panel: PanelContainer, parent: Node)

signal link_camera(rt2d: RemoteTransform2D)
signal set_camera_limit(limit_ltrb: Vector4i)
signal position_camera(pos: Vector2)
signal fade_out(enter: bool)
signal fade_out_finished

signal add_item(itemData: ItemData)
signal add_multiple_item(itemData: ItemData, quantity: int)
signal erase_item(slotID: int)
signal swap_item(slotID_1: int, slotID_2)
signal remove_item(slotID: int)
signal change_area(areaData: AreaData)

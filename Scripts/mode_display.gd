extends Control
@onready var modeLabel: Label = $MarginContainer/Label

func _ready() -> void:
	EventBus.mode_display.connect(set_mode)

func set_mode(mode: GlobalEnum.BuildMode) -> void:
	match mode:
		GlobalEnum.BuildMode.PLACE:
			modeLabel.text = "PLACEMENT MODE"
		GlobalEnum.BuildMode.DESTROY:
			modeLabel.text = "DESTROY MODE"
		GlobalEnum.BuildMode.OFF:
			modeLabel.text = ""

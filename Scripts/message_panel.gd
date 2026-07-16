extends PanelContainer

@onready var title: Label = $MarginContainer/ScrollContainer/VBoxContainer/Title
@onready var message: RichTextLabel = $MarginContainer/ScrollContainer/VBoxContainer/Message

var messageData: MessageData
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if messageData:
		title.text = messageData.title
		message.text = messageData.message
	else:
		print("Message Data Not Set")

func close_panel() -> void:
	queue_free()

extends Label
class_name WindowTitle

@onready var data_store : DataStore = get_node("/root/DataStore")

func _ready():
    text = data_store.tournament.name

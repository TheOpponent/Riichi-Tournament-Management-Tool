extends HBoxContainer
class_name SettingDisplay

@onready var name_label : Label = $NameContainer/Label
@onready var value_label : Label = $ValueContainer/Label

func set_text(new_name : String, new_value : String) -> void:
    name_label.text = new_name
    value_label.text = new_value
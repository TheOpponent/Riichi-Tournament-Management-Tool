extends HBoxContainer
class_name UmaDisplay

@onready var name_label : Label = $NameContainer/Name

@onready var label_1 : Label = $ValuesContainer/HBoxContainer/First
@onready var label_2 : Label = $ValuesContainer/HBoxContainer/Second
@onready var label_3 : Label = $ValuesContainer/HBoxContainer/Third
@onready var label_4 : Label = $ValuesContainer/HBoxContainer/Fourth

func set_values(new_name : String, values : Array[float]):
    name_label.text = new_name

    label_1.text = str(values[0])
    label_2.text = str(values[1])
    label_3.text = str(values[2])
    if values.size() > 3:
        label_4.text = str(values[3])
    else:
        label_4.visible = false

extends VBoxContainer
class_name ColumnPicker

@onready var one : OptionButton = $One
@onready var two : OptionButton = $Two
@onready var three : OptionButton = $Three
@onready var four : OptionButton = $Four

var column_size = 4

signal row_changed

func _ready():
    one.item_selected.connect(_on_wind_changed)
    two.item_selected.connect(_on_wind_changed)
    three.item_selected.connect(_on_wind_changed)
    four.item_selected.connect(_on_wind_changed)

func set_value(index, value):
    match index:
        0:
            one.selected = value
        1:
            two.selected = value
        2:
            three.selected = value
        3:
            four.selected = value

func get_value(index):
    match index:
        0:
            return one.selected
        1:
            return two.selected
        2:
            return three.selected
        3:
            return four.selected

func get_value_arr():
    var values = [one.selected, two.selected, three.selected]
    if column_size == 4:
        values.append(four.selected)
    return values

func _on_wind_changed(_selected):
    row_changed.emit()

func set_column_size(new_size : int):
    if new_size != column_size:
        column_size = new_size
        if column_size == 3:
            four.visible = false
        else:
            four.visible = true
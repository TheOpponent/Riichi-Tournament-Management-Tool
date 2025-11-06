extends VBoxContainer
class_name ColumnIdInput

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var one : SpinBox = $One
@onready var two : SpinBox = $Two
@onready var three : SpinBox = $Three
@onready var four : SpinBox = $Four

var column_size = 4

signal id_changed

func _ready():
    one.value_changed.connect(on_changed.bind(0))
    two.value_changed.connect(on_changed.bind(1))
    three.value_changed.connect(on_changed.bind(2))
    four.value_changed.connect(on_changed.bind(3))

    data_store.players_updated.connect(on_players_updated)
    on_players_updated()

func set_value(index, value):
    match index:
        0:
            one.value = value
        1:
            two.value = value
        2:
            three.value = value
        3:
            four.value = value

func get_value_arr():
    var values = [int(one.value), int(two.value), int(three.value)]
    if column_size == 4:
        values.append(int(four.value))
    return values

func on_changed(value, index):
    id_changed.emit(value, index)

func on_players_updated():
    var max_id = 0

    for player_id in data_store.players_by_id:
        if player_id > max_id:
            max_id = player_id
    
    one.max_value = max_id
    two.max_value = max_id
    three.max_value = max_id
    if column_size == 4:
        four.max_value = max_id

func set_column_size(new_size : int):
    if new_size != column_size:
        column_size = new_size
        if column_size == 3:
            four.visible = false
        else:
            four.visible = true
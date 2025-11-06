extends HBoxContainer
class_name UmaContainer

@onready var title : Label = $HBoxContainer/MarginContainer/Label

@onready var input_1 : NumericLineEdit = $UmaInputContainer/Uma1/Uma1
@onready var input_2 : NumericLineEdit = $UmaInputContainer/Uma2/Uma2
@onready var input_3 : NumericLineEdit = $UmaInputContainer/Uma3/Uma3
@onready var input_4 : NumericLineEdit = $UmaInputContainer/Uma4/Uma4

@onready var container_4 = $UmaInputContainer/Uma4

var player_count = 4

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func export() -> Array[float]:
    var values : Array[float] = []
    values.append(input_1.get_value())
    values.append(input_2.get_value())
    values.append(input_3.get_value())
    if player_count == 4:
        values.append(input_4.get_value())
    return values

func set_player_count(count : int) -> void:
    player_count = count
    if player_count == 4:
        container_4.visible = true
    else:
        container_4.visible = false

func set_title(new_title : String) -> void:
    title.text = new_title

func set_defaults(defaults : Array) -> void:
    input_1.set_default(defaults[0])
    input_2.set_default(defaults[1])
    input_3.set_default(defaults[2])

    if player_count == 4:
        input_4.set_default(defaults[3])

extends VBoxContainer
class_name ColumnInput

@onready var data_store = get_node("/root/DataStore")

@onready var one : NumericLineEdit = $One
@onready var two : NumericLineEdit = $Two
@onready var three : NumericLineEdit = $Three
@onready var four : NumericLineEdit = $Four

var column_size = 4

signal row_changed

func _ready():
    one.text_changed.connect(_on_change)
    two.text_changed.connect(_on_change)
    three.text_changed.connect(_on_change)
    four.text_changed.connect(_on_change)

func set_value(index, value):
    match index:
        0:
            one.text = str(value)
            one.placeholder_text = str(value)
        1:
            two.text = str(value)
            two.placeholder_text = str(value)
        2:
            three.text = str(value)
            three.placeholder_text = str(value)
        3:
            four.text = str(value)
            four.placeholder_text = str(value)

func set_score_value(index, value):
    set_value(index, data_store.score_format(value) % [abs(value)])

func get_value(index):
    match index:
        0:
            return one.get_value()
        1:
            return two.get_value()
        2:
            return three.get_value()
        3:
            return four.get_value()

func get_value_arr():
    var values = [one.get_value(), two.get_value(), three.get_value()]
    if column_size == 4:
        values.append(four.get_value())
    return values

func _on_change(_new_text : String):
    row_changed.emit()

func set_column_size(new_size : int):
    if new_size != column_size:
        column_size = new_size
        if column_size == 3:
            four.visible = false
        else:
            four.visible = true

func sim_yonma_scores():
    var scores = [300, 300, 300, 300]

    for hand in range(8):
        var outcome = randf()
        var han = randi_range(1, 6)
        var fu = randi_range(0, 3) * 10 + 20
        if outcome < 0.34:
            # tsumo
            var winner = randi_range(0, 3)
            var dealer = winner == hand % 4
            var hand_value = 0
            var dealer_payment = 0
            var nondealer_payment = 0

            if han == 6:
                hand_value = 120
                dealer_payment = 60
                nondealer_payment = 30
                if dealer:
                    hand_value = 180
            elif han == 5 or han == 4:
                # kiriage mangan, no 20 fu ron
                hand_value = 80
                dealer_payment = 40
                nondealer_payment = 20
                if dealer:
                    hand_value = 120
            elif han == 3:
                if fu == 50:
                    hand_value = 64
                    dealer_payment = 32
                    nondealer_payment = 16
                    if dealer:
                        hand_value = 96
                elif fu == 40:
                    hand_value = 52
                    dealer_payment = 26
                    nondealer_payment = 13
                    if dealer:
                        hand_value = 78
                else:
                    hand_value = 40
                    dealer_payment = 20
                    nondealer_payment = 10
                    if dealer:
                        hand_value = 60
            elif han == 2:
                if fu == 50:
                    hand_value = 32
                    dealer_payment = 16
                    nondealer_payment = 8
                    if dealer:
                        hand_value = 48
                elif fu == 40:
                    hand_value = 27
                    dealer_payment = 13
                    nondealer_payment = 7
                    if dealer:
                        hand_value = 39
                else:
                    hand_value = 20
                    dealer_payment = 10
                    nondealer_payment = 5
                    if dealer:
                        hand_value = 30
            elif han == 1:
                if fu == 50:
                    hand_value = 16
                    dealer_payment = 8
                    nondealer_payment = 4
                    if dealer:
                        hand_value = 24
                elif fu == 40:
                    hand_value = 15
                    dealer_payment = 7
                    nondealer_payment = 4
                    if dealer:
                        hand_value = 21
                else:
                    hand_value = 11
                    dealer_payment = 5
                    nondealer_payment = 3
                    if dealer:
                        hand_value = 15
            for i in range(4):
                if i == winner:
                    scores[i] += hand_value
                else:
                    if dealer or i == hand % 4:
                        scores[i] -= dealer_payment
                    else:
                        scores[i] -= nondealer_payment
        else:
            var winner = randi_range(0, 3)
            var loser = randi_range(0, 3)
            var dealer = winner == hand % 4
            var hand_value = 0
            # ron
            if han == 6:
                hand_value = 120
                if dealer:
                    hand_value = 180
            elif han == 5 or han == 4:
                # kiriage mangan, no 20 fu ron
                hand_value = 80
                if dealer:
                    hand_value = 120
            elif han == 3:
                if fu == 50:
                    hand_value = 64
                    if dealer:
                        hand_value = 96
                elif fu == 40:
                    hand_value = 52
                    if dealer:
                        hand_value = 77
                else:
                    hand_value = 39
                    if dealer:
                        hand_value = 58
            elif han == 2:
                if fu == 50:
                    hand_value = 32
                    if dealer:
                        hand_value = 48
                elif fu == 40:
                    hand_value = 26
                    if dealer:
                        hand_value = 39
                else:
                    hand_value = 20
                    if dealer:
                        hand_value = 29
            elif han == 1:
                if fu == 50:
                    hand_value = 16
                    if dealer:
                        hand_value = 24
                elif fu == 40:
                    hand_value = 13
                    if dealer:
                        hand_value = 20
                else:
                    hand_value = 10
                    if dealer:
                        hand_value = 15
            
            scores[winner] += hand_value
            scores[loser] -= hand_value
    
    set_value(0, scores[0] * 100)
    set_value(1, scores[1] * 100)
    set_value(2, scores[2] * 100)
    set_value(3, scores[3] * 100)

extends VBoxContainer
class_name CutCreation

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var error_pane : VBoxContainer = $Error
@onready var not_enough_rounds : Label = $Error/NotEnoughRoundsLabel
@onready var ties : Label = $Error/TiesLabel
@onready var error_confirm : Button = $Error/Button

@onready var controls : VBoxContainer = $Control

@onready var cut_start_round : NumericLineEdit = $Control/CutStartRoundContainer/NumericLineEdit
@onready var cut_end_round : NumericLineEdit = $Control/CutEndRoundContainer/NumericLineEdit
@onready var player_count : NumericLineEdit = $Control/PlayerCountContainer/NumericLineEdit
@onready var score_modification : OptionButton = $Control/ScoreModificationContainer/OptionButton

@onready var confirm_button : Button = $Control/Buttons/ConfirmButton
@onready var cancel_button : Button = $Control/Buttons/CancelButton

signal cut_creation_finished

func _ready():
    error_confirm.pressed.connect(_quit)
    cancel_button.pressed.connect(_quit)

    confirm_button.pressed.connect(_on_create_cut)

    data_store.standings_updated.connect(render)

    render()

func render():
    var max_round_present = data_store.tournament.next_round - 1
    var max_cut_round = 0
    for cut in data_store.tournament.cuts:
        if cut.end_round > max_cut_round:
            max_cut_round = cut.end_round
    
    if max_cut_round >= max_round_present:
        error_pane.visible = true
        not_enough_rounds.visible = true
        ties.visible = false
        controls.visible = false
    else:
        error_pane.visible = false
        controls.visible = true
        cut_start_round.set_default(max_cut_round + 1)
        cut_end_round.set_default(max_round_present)

func _on_create_cut():
    var cut : Cut = Cut.new()

    cut.start_round = int(cut_start_round.get_value())
    cut.end_round = int(cut_end_round.get_value())

    cut.score_modification = score_modification.get_selected_id() as Cut.ScoreModification
    cut.player_count = int(player_count.get_value())

    if data_store.create_cut(cut):
        error_pane.visible = true
        not_enough_rounds.visible = false
        ties.visible = true
        controls.visible = false
    else:
        _quit()

func _quit():
    cut_creation_finished.emit()
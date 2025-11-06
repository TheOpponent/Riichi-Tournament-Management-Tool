extends HBoxContainer
class_name HanchanHistory

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var round_selector : OptionButton = $HistoryPane/RoundSelector/RoundSelectorLayout/Selector
@onready var history_tree : PlayerHanchanHistory = $HistoryPane/HanchanHistory/HanchanHistory
@onready var players_tree : Tree = $HistoryPane/HanchanHistory/Players

@onready var score_input : ScoreInput = $ControlsPane/SettingsContainer/Settings
@onready var hanchan_creation : HanchanCreation = $ControlsPane/SettingsContainer/HanchanCreation

@onready var add_hanchan_button : Button = $HistoryPane/AddHanchanButton

func _ready():
    data_store.standings_updated.connect(_on_standings_updated)
    round_selector.item_selected.connect(_on_round_selected)

    history_tree.item_selected.connect(_on_hanchan_selected)

    add_hanchan_button.pressed.connect(_on_create_hanchan)

    score_input.visible = false
    hanchan_creation.visible = false

    score_input.submit_table.connect(_on_submit_table)
    score_input.cancel_edit.connect(_on_cancel_edit)

    hanchan_creation.create_table.connect(_on_create_table)
    hanchan_creation.cancel_table_creation.connect(_on_cancel_create_table)

    _on_standings_updated()

func _on_create_hanchan() -> void:
    history_tree.visible = false
    players_tree.visible = true

    add_hanchan_button.visible = false
    hanchan_creation.visible = true

    hanchan_creation.initialize()

func _on_hanchan_selected() -> void:
    score_input.visible = true
    add_hanchan_button.visible = false

    var selected = history_tree.get_selected()
    if selected.get_parent() != history_tree.get_root():
        selected = selected.get_parent()
    
    var round_id = 0
    var table_id = 0

    var title = selected.get_text(0)
    if selected.get_text(0).contains("Round"):
        title = title.replace("Round ", "").replace(" Table ", "")
        var values = title.split(",")
        round_id = int(values[0])
        table_id = int(values[1])
    else:
        table_id = int(title.replace("Table ", ""))
    
    score_input.initialize(data_store.get_table(round_id, table_id))

func _on_standings_updated() -> void:
    var max_round = data_store.tournament.next_round - 1
    if round_selector.item_count < max_round + 2:
        for i in range(round_selector.item_count - 1, max_round + 1):
            round_selector.add_item(str(i))


func _on_round_selected(index : int) -> void:
    history_tree.set_filter(index - 1)

func _on_submit_table(table : Table) -> void:
    data_store.update_table(table)
    score_input.visible = false
    add_hanchan_button.visible = true

func _on_cancel_edit() -> void:
    score_input.visible = false
    add_hanchan_button.visible = true
    history_tree.deselect_all()

func _on_create_table(table : Table) -> void:
    hanchan_creation.visible = false
    history_tree.visible = true
    players_tree.visible = false
    add_hanchan_button.visible = true

    data_store.add_single_table(table)

func _on_cancel_create_table() -> void:
    hanchan_creation.visible = false
    history_tree.visible = true
    players_tree.visible = false
    add_hanchan_button.visible = true

extends VBoxContainer
class_name CutManagement

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var cuts_tree : Tree = $CutsTree
@onready var delete_button : Button = $DeleteButton
@onready var exit_button : Button = $ExitButton

signal delete_cut
signal cut_manager_exit

func _ready():
    cuts_tree.set_column_title(0, "Player Count")
    cuts_tree.set_column_title(1, "Score Modification")
    cuts_tree.set_column_title(2, "Rounds")

    delete_button.pressed.connect(_on_delete)
    exit_button.pressed.connect(_on_exit)

    data_store.standings_updated.connect(render)
    render()

func render():
    cuts_tree.clear()
    cuts_tree.create_item()

    var cuts = data_store.tournament.cuts
    for cut in cuts:
        var row = cuts_tree.create_item()

        row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

        row.set_text(0, str(cut.player_count))
        row.set_text(1, cut.get_score_modification_string())
        row.set_text(2, "%d-%d" % [cut.start_round, cut.end_round])

        row.set_editable(0, false)
        row.set_editable(1, false)
        row.set_editable(2, false)

func _on_delete():
    if cuts_tree.get_selected() == null:
        return
    delete_cut.emit(cuts_tree.get_selected().get_index() - 1)

func _on_exit():
    cut_manager_exit.emit()

extends Tree
class_name PlayerList

@onready var data_store : DataStore = get_node("/root/DataStore")

enum SortColumn { ID, NAME, AFFILIATION, SCORE }

signal player_deselected

var sort_column = 0
var sort_asc = true

func _ready():
    set_column_title(0, "Player ID")
    set_column_title(1, "Player Name")
    set_column_title(2, "Affiliation")
    set_column_title(3, "Score")

    set_column_custom_minimum_width(0, 0)
    set_column_custom_minimum_width(1, 200)
    set_column_custom_minimum_width(2, 100)
    set_column_custom_minimum_width(3, 0)

    data_store.players_updated.connect(render_players)
    render_players()

    empty_clicked.connect(_empty_clicked)
    nothing_selected.connect(_clear_selection)
    column_title_clicked.connect(_sort_players)

func selected_id() -> int:
    var selected = get_selected()
    if selected:
        return int(selected.get_text(0))
    return 0

func _empty_clicked(_position, _mouse_button_index):
    deselect_all()
    player_deselected.emit()

func _clear_selection():
    deselect_all()
    player_deselected.emit()

func render_players() -> void:
    clear()
    create_item()

    var scores = data_store.get_scores()
    var player_list = []

    for player in data_store.tournament.registered_players:
        player_list.append([player.id, player.name, player.affiliation, scores.get(player.id, 0)])
    
    player_list.sort_custom(func(a, b): return a[sort_column] < b[sort_column] if sort_asc else a[sort_column] > b[sort_column])

    for player in player_list:
        var row = create_item()
        var player_score = scores.get(player[0], 0)

        row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(3, TreeItem.CELL_MODE_STRING)

        row.set_text(0, str(player[0]))
        row.set_text(1, player[1])
        row.set_text(2, player[2])
        row.set_text(3, data_store.score_format(player_score) % [abs(player[3])])

        row.set_editable(0, false)
        row.set_editable(1, false)
        row.set_editable(2, false)
        row.set_editable(3, false)

func _sort_players(column, _mouse_button):
    if column == sort_column:
        sort_asc = not sort_asc
    else:
        sort_column = column
        sort_asc = column != SortColumn.SCORE
    render_players()
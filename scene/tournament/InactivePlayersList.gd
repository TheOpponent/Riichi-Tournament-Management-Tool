extends Tree
class_name InactivePlayerList

@onready var data_store = get_node("/root/DataStore")

func _ready():
    set_column_title(0, "Player ID")
    set_column_title(1, "Player Name")
    set_column_title(2, "Affiliation")
    set_column_title(3, "Score")

    set_column_custom_minimum_width(0, 0)
    set_column_custom_minimum_width(1, 200)
    set_column_custom_minimum_width(2, 100)
    set_column_custom_minimum_width(3, 0)

    item_edited.connect(_on_item_edited)
    data_store.players_updated.connect(render_players)

    render_players()

func enable_edit() -> void:
    select_mode = SELECT_SINGLE
    var rows = get_root().get_children()
    for row in rows:
        row.set_editable(1, true)
        row.set_editable(2, true)

func disable_edit() -> void:
    select_mode = SELECT_ROW
    var rows = get_root().get_children()
    for row in rows:
        row.set_editable(1, false)
        row.set_editable(2, false)

func _on_item_edited() -> void:
    data_store.update_inactive_players(export())

func selected_id() -> int:
    var selected = get_selected()
    if selected:
        return int(selected.get_text(0))
    return 0

func create_player(next_id : int) -> void:
    var row = create_item()

    row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
    row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
    row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

    row.set_text(0, str(next_id))
    row.set_text(1, "Freed Jyanshi %d" % [next_id])
    row.set_text(2, "Riichi Nomi NYC")

    row.set_editable(0, false)
    row.set_editable(1, true)
    row.set_editable(2, true)

    data_store.update_inactive_players(export())

func render_players() -> void:
    clear()
    create_item()

    var scores = data_store.get_scores()
    for player in data_store.tournament.inactive_players:
        var row = create_item()

        row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

        row.set_text(0, str(player.id))
        row.set_text(1, player.name)
        row.set_text(2, player.affiliation)
        row.set_text(3, data_store.score_format(scores.get(player.id, 0)) % [abs(scores.get(player.id, 0))])

        var editable = select_mode == SELECT_SINGLE

        row.set_editable(0, false)
        row.set_editable(1, editable)
        row.set_editable(2, editable)
        row.set_editable(3, false)

func export() -> Array[Player]:
    var players : Array[Player] = []
    for row in get_root().get_children():
        var player = Player.new()
        player.id = int(row.get_text(0))
        player.name = row.get_text(1)
        player.affiliation = row.get_text(2)
        players.append(player)
    return players
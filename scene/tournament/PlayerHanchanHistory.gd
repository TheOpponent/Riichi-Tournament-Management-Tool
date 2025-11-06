extends Tree
class_name PlayerHanchanHistory

@onready var data_store = get_node("/root/DataStore")

var shuugi
var player_inspected : int = 0
var round_filter : int = -1

func _ready():
    shuugi = data_store.tournament.settings.shuugi
    if shuugi:
        columns = 6

        set_column_title(0, "Player ID")
        set_column_title(1, "Player Name")
        set_column_title(2, "Points")
        set_column_title(3, "Shuugi")
        set_column_title(4, "Penalty")
        set_column_title(5, "Score")

        set_column_custom_minimum_width(0, 0)
        set_column_custom_minimum_width(1, 200)
        set_column_custom_minimum_width(2, 0)
        set_column_custom_minimum_width(3, 0)
        set_column_custom_minimum_width(4, 0)
        set_column_custom_minimum_width(5, 0)
    else:
        columns = 5

        set_column_title(0, "Player ID")
        set_column_title(1, "Player Name")
        set_column_title(2, "Points")
        set_column_title(3, "Penalty")
        set_column_title(4, "Score")

        set_column_custom_minimum_width(0, 0)
        set_column_custom_minimum_width(1, 200)
        set_column_custom_minimum_width(2, 0)
        set_column_custom_minimum_width(3, 0)
        set_column_custom_minimum_width(4, 0)
    
    render()

    data_store.standings_updated.connect(render)

func set_filter(round : int) -> void:
    round_filter = round
    render()

func inspect_player(player_id : int) -> void:
    player_inspected = player_id
    render()

func render() -> void:
    clear()
    create_item()

    var hanchan_history = []
    if player_inspected == 0:
        hanchan_history = data_store.get_hanchan_history()
    else:
        hanchan_history = data_store.get_hanchan_history_for_player(player_inspected)

    for table in hanchan_history:
        if round_filter != -1 and table.round_id != round_filter:
            continue

        var table_scores = table.score_table_arr(data_store.tournament.settings)

        var table_row : TreeItem = create_item()
        table_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        if table.round_id == 0:
            table_row.set_text(0, "Table %d" % table.table_id)
        else:
            table_row.set_text(0, "Round %d, Table %d" % [table.round_id, table.table_id])
        table_row.set_editable(0, false)
        
        for index in range(table.player_ids.size()):
            var player_row = table_row.create_child()
            var player_data = data_store.get_player(table.player_ids[index])

            player_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(3, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(4, TreeItem.CELL_MODE_STRING)
            if shuugi:
                player_row.set_cell_mode(5, TreeItem.CELL_MODE_STRING)
            
            player_row.set_text(0, str(player_data.id))
            player_row.set_text(1, player_data.name)
            if table.is_complete(data_store.tournament.settings):
                player_row.set_text(2, str(table.final_points[index]))
                var player_score = table_scores[index]
                var penalty = table.penalties[index]
                var score_string = data_store.score_format(player_score) % [abs(player_score)]
                if shuugi:
                    player_row.set_text(3, str(table.final_shuugi[index]))
                    player_row.set_text(4, str(penalty))
                    player_row.set_text(5, score_string)
                else:
                    player_row.set_text(3, str(penalty))
                    player_row.set_text(4, score_string)
            
            player_row.set_editable(0, false)
            player_row.set_editable(1, false)
            player_row.set_editable(2, false)
            player_row.set_editable(3, false)
            player_row.set_editable(4, false)
            if shuugi:
                player_row.set_editable(5, false)

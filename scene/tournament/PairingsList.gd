extends Tree
class_name PairingsList

@onready var data_store : DataStore = get_node("/root/DataStore")

var tables = []

# Called when the node enters the scene tree for the first time.
func _ready():
    set_column_title(0, "Player ID")
    set_column_title(1, "Player Name")
    set_column_title(2, "Seat Wind")

func wind_string(wind):
    match wind:
        0: return "East"
        1: return "South"
        2: return "West"
        3: return "North"
        _: return "Unknown"

func render(new_tables, byes):
    clear()
    create_item()

    tables = new_tables.duplicate()
    var table_id = 1
    for table in tables:
        var table_row = create_item()
        table_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        table_row.set_text(0, "Table %d" % [table_id])
        table_row.set_editable(0, false)

        table.table_id = table_id
        table_id += 1

        for index in range(table.player_ids.size()):
            var player_id = table.player_ids[index]
            var player_data = data_store.get_player(player_id)

            var player_row = table_row.create_child()

            var seat_wind = wind_string(table.player_seats[index]) if table.player_seats.size() > 0 else ""

            player_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

            player_row.set_text(0, str(player_id))
            player_row.set_text(1, player_data.name)
            player_row.set_text(2, seat_wind)
    
    if byes.size() > 0:
        var byes_row = create_item()
        byes_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        byes_row.set_text(0, "Byes")
        byes_row.set_editable(0, false)

        for player_id in byes:
            var player_data = data_store.get_player(player_id)
            var player_row = byes_row.create_child()

            player_row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
            player_row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

            player_row.set_text(0, str(player_id))
            player_row.set_text(1, player_data.name)
            player_row.set_text(2, "")

func export_tables():
    return tables

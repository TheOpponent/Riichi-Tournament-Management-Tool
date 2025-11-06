extends VBoxContainer
class_name HanchanCreation

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var round_label : Label = $RoundName/Label

@onready var player_id_column : ColumnIdInput = $Scorer/PlayerIdMargin/PlayerId
@onready var player_name_column : ColumnLabel = $Scorer/PlayerNameMargin/PlayerName
@onready var seat_wind_column : ColumnPicker = $Scorer/SeatWindMargin/SeatWind

@onready var create_table_button : Button = $ButtonsContainer/Buttons/Confirm
@onready var cancel_button : Button = $ButtonsContainer/Buttons/Cancel

var new_table : Table = Table.new()

signal create_table
signal cancel_table_creation

func _ready():
    player_id_column.id_changed.connect(set_player_name)

    create_table_button.pressed.connect(on_create_table)
    cancel_button.pressed.connect(on_cancel)

    if data_store.tournament.settings.game_type == TournamentSettings.GameType.SANMA:
        player_id_column.set_column_size(3)
        player_name_column.set_column_size(3)
        seat_wind_column.set_column_size(3)

func initialize() -> void:
    new_table = Table.new()
    visible = true

    var next_table_id = data_store.get_next_table_id(0)

    new_table.round_id = 0
    new_table.table_id = next_table_id

    round_label.text = "Table %d" % [new_table.table_id]

    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    for i in range(table_size):
        player_id_column.set_value(i, 0)
        set_player_name(0, i)

        seat_wind_column.set_value(i, i)

func export() -> Table:
    new_table.player_ids = player_id_column.get_value_arr()
    new_table.player_seats = seat_wind_column.get_value_arr()

    return new_table

func set_player_name(id : int, index : int) -> void:
    player_name_column.set_text(index, data_store.get_player_name(id))

func on_create_table() -> void:
    create_table.emit(export())

func on_cancel() -> void:
    cancel_table_creation.emit()
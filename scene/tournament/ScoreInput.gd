extends VBoxContainer
class_name ScoreInput

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var round_label : Label = $RoundName/Label

@onready var player_id_column : ColumnIdInput = $Scorer/PlayerIdMargin/PlayerId
@onready var player_name_column : ColumnLabel = $Scorer/PlayerNameMargin/PlayerName
@onready var seat_wind_column : ColumnPicker = $Scorer/SeatWindMargin/SeatWind
@onready var points_column : ColumnInput = $Scorer/PointsMargin/Points
@onready var shuugi_column : ColumnInput = $Scorer/ShuugiMargin/Shuugi
@onready var penalty_column : ColumnInput = $Scorer/PenaltyMargin/Penalty
@onready var score_column : ColumnInput = $Scorer/ScoreMargin/Score

@onready var shuugi_column_margin : MarginContainer = $Scorer/ShuugiMargin

@onready var missing_points_label : Label = $MissingContainer/Root/Values/Points/Label
@onready var missing_shuugi_label : Label = $MissingContainer/Root/Values/Shuugi/Label

@onready var missing_shuugi_left : MarginContainer = $MissingContainer/Root/Labels/Shuugi
@onready var missing_shuugi_right : MarginContainer = $MissingContainer/Root/Values/Shuugi

@onready var modify_table_button : Button = $ButtonsContainer/Buttons/ModifyTable
@onready var submit_table_button : Button = $ButtonsContainer/Buttons/Confirm
@onready var cancel_button : Button = $ButtonsContainer/Buttons/Cancel

var new_table : Table = Table.new()

signal submit_table
signal cancel_edit

func _ready():
    player_id_column.id_changed.connect(set_player_name)

    seat_wind_column.row_changed.connect(on_score_change)

    points_column.row_changed.connect(on_score_change)
    shuugi_column.row_changed.connect(on_score_change)
    penalty_column.row_changed.connect(on_score_change)

    modify_table_button.pressed.connect(on_modify_table)
    submit_table_button.pressed.connect(on_submit_table)
    cancel_button.pressed.connect(on_cancel)

    if data_store.tournament.settings.game_type == TournamentSettings.GameType.SANMA:
        player_id_column.set_column_size(3)
        player_name_column.set_column_size(3)
        seat_wind_column.set_column_size(3)
        points_column.set_column_size(3)
        shuugi_column.set_column_size(3)
        penalty_column.set_column_size(3)
        score_column.set_column_size(3)

func initialize(table : Table) -> void:
    visible = true

    var settings = data_store.tournament.settings

    new_table.round_id = table.round_id
    new_table.table_id = table.table_id

    if table.round_id == 0:
        round_label.text = "Table %d" % [table.table_id]
    else:
        round_label.text = "Round %d, Table %d" % [table.round_id, table.table_id]

    for i in range(table.player_ids.size()):
        if table.player_ids.size() > i:
            player_id_column.set_value(i, table.player_ids[i])
            set_player_name(table.player_ids[i], i)
        else:
            player_id_column.set_value(i, 0)
            score_column.set_value(i, 0.0)
            set_player_name(0, i)

        if table.player_seats.size() > i:
            seat_wind_column.set_value(i, table.player_seats[i])
        else:
            seat_wind_column.set_value(i, i)

        if table.final_points.size() > i:
            points_column.set_value(i, table.final_points[i])
        else:
            points_column.set_value(i, settings.start_points)

        if data_store.tournament.settings.shuugi and table.final_shuugi.size() > i:
            shuugi_column_margin.visible = true
            missing_shuugi_left.visible = true
            missing_shuugi_right.visible = true

            shuugi_column.set_value(i, table.final_shuugi[i])
        elif data_store.tournament.settings.shuugi:
            shuugi_column_margin.visible = true
            missing_shuugi_left.visible = true
            missing_shuugi_right.visible = true

            shuugi_column.set_value(i, settings.start_shuugi)
        else:
            shuugi_column_margin.visible = false
            missing_shuugi_left.visible = false
            missing_shuugi_right.visible = false

        if table.penalties.size() > i:
            penalty_column.set_value(i, table.penalties[i])
        else:
            penalty_column.set_value(i, 0)
    
    # points_column.sim_yonma_scores()
    
    on_score_change()

func export() -> Table:
    new_table.player_ids = player_id_column.get_value_arr()
    new_table.player_seats = seat_wind_column.get_value_arr()

    new_table.final_points = points_column.get_value_arr()
    if data_store.tournament.settings.shuugi:
        new_table.final_shuugi = shuugi_column.get_value_arr()
    new_table.penalties = penalty_column.get_value_arr()

    new_table.left_over_kyotaku = float(missing_points())

    return new_table

func export_without_scores() -> Table:
    new_table.player_ids = player_id_column.get_value_arr()
    new_table.player_seats = seat_wind_column.get_value_arr()

    new_table.final_points = [] 
    if data_store.tournament.settings.shuugi:
        new_table.final_shuugi = []
    new_table.penalties = []

    return new_table

func missing_points() -> int:
    var players_per_table = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var points = data_store.tournament.settings.start_points * players_per_table

    var points_arr = points_column.get_value_arr()

    for i in range(points_arr.size()):
        points -= points_arr[i]

    return points

func missing_shuugi() -> int:
    if not data_store.tournament.settings.shuugi:
        return 0

    var players_per_table = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var shuugi = data_store.tournament.settings.start_shuugi * players_per_table

    var shuugi_arr = shuugi_column.get_value_arr()

    for i in range(shuugi_arr.size()):
        shuugi -= shuugi_arr[i]

    return shuugi

func on_score_change() -> void:
    var scores = export().score_table_arr(data_store.tournament.settings)

    for i in range(new_table.player_ids.size()):
        score_column.set_score_value(i, scores[i])
    
    var short_points = missing_points()
    var short_shuugi = missing_shuugi()
    
    if short_points != 0:
        missing_points_label.text = "%d" % [short_points]
        missing_points_label.modulate = Color(1, 0, 0, 1)
    else:
        missing_points_label.text = "0"
        missing_points_label.modulate = Color(1, 1, 1, 1)
    
    if data_store.tournament.settings.shuugi:
        if short_shuugi != 0:
            missing_shuugi_label.text = "%d" % [short_shuugi]
            missing_shuugi_label.modulate = Color(1, 0, 0, 1)
        else:
            missing_shuugi_label.text = "0"
            missing_shuugi_label.modulate = Color(1, 1, 1, 1)

func set_player_name(id : int, index : int) -> void:
    player_name_column.set_text(index, data_store.get_player_name(id))

func on_modify_table() -> void:
    submit_table.emit(export_without_scores())

func on_submit_table() -> void:
    submit_table.emit(export())

func on_cancel() -> void:
    cancel_edit.emit()
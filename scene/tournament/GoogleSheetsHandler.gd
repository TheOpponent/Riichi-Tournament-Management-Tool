extends VBoxContainer
class_name GoogleSheetsHandler

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var script_id_field : LineEdit = $Control/ScriptIdContainer/LineEdit

@onready var export_button : Button = $Control/Buttons/ExportButton
@onready var import_button : Button = $Control/Buttons/ImportButton

@onready var error_label : Label = $Error/Label
@onready var error_button : Button = $Error/Button

@onready var hide_handler_button : Button = $Control/DoneButton

@onready var error_block : VBoxContainer = $Error
@onready var control_block : VBoxContainer = $Control

@onready var request : HTTPRequest = $HTTPRequest

enum RequestStatus { NONE, EXPORT, IMPORT }
var request_in_flight : RequestStatus = RequestStatus.NONE
var get_url_format : String = "https://script.google.com/macros/s/%s/exec?tableSize=%d&shuugi=%s"
var post_url_format : String = "https://script.google.com/macros/s/%s/exec"

signal hide_sheets_handler

func _ready():
    error_block.visible = false
    control_block.visible = true

    script_id_field.text = data_store.tournament.settings.script_id

    script_id_field.text_changed.connect(_on_script_id_changed)

    export_button.pressed.connect(_on_export_pressed)
    import_button.pressed.connect(_on_import_pressed)

    hide_handler_button.pressed.connect(_on_hide_handler)

    error_button.pressed.connect(_on_error_button_clicked)

    request.request_completed.connect(_on_request_completed)

func _on_export_pressed():
    if request_in_flight == RequestStatus.NONE:
        request_in_flight = RequestStatus.EXPORT

        var round_number = data_store.tournament.next_round - 1
        var standings = []
        var tables = []
        var shuugi = data_store.tournament.settings.shuugi

        var raw_standings = data_store.get_scores()
        for player_data in data_store.tournament.registered_players:
            standings.append([player_data.id, player_data.name, raw_standings.get(player_data.id, 0)])
        standings.sort_custom(func(a, b): return a[2] > b[2])
        for i in range(0, len(standings)):
            standings[i][2] = data_store.score_format(standings[i][2]) % [abs(standings[i][2])]
            standings[i].push_front(i + 1)

        var raw_tables = data_store.get_round(round_number)
        for table in raw_tables:
            var table_data = []
            for player_id in table.player_ids:
                table_data.append([player_id, data_store.get_player(player_id).name])
            tables.append(table_data)

        var body = {
            "roundNumber": round_number,
            "standings": standings,
            "tables": tables,
            "shuugi": shuugi
        }

        request.request(post_url_format % [script_id_field.text], [], HTTPClient.METHOD_POST, JSON.stringify(body))

func _on_import_pressed():
    if request_in_flight == RequestStatus.NONE:
        request_in_flight = RequestStatus.IMPORT
        var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3
        var shuugi = data_store.tournament.settings.shuugi
        request.request(get_url_format % [script_id_field.text, table_size, shuugi])

func _on_request_completed(_result, response_code, _headers, body):
    var parser = JSON.new()
    parser.parse(body.get_string_from_utf8())
    if request_in_flight == RequestStatus.IMPORT:
        if response_code == 200:
                error_block.visible = false
                control_block.visible = true
                _handle_import(parser.data)
        else:
            _show_message("Error %d: %s" % [response_code, parser.data["error"]["message"]])
    else:
        _show_message("Export complete.")
    request_in_flight = RequestStatus.NONE

func _on_hide_handler():
    hide_sheets_handler.emit()

func _on_error_button_clicked():
    error_block.visible = false
    control_block.visible = true

func _on_script_id_changed(new_text : String):
    data_store.tournament.settings.script_id = new_text

func _handle_import(tables):
    var round_number = tables[0]
    var table_data = tables.slice(1)

    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    for table in table_data:
        var table_obj = data_store.get_table(round_number, table[0])

        for score in table.slice(1):
            var player_index = table_obj.player_index(score[0])
            if player_index == -1:
                _show_message("Error when importing table %d: Player %s in spreadsheet not present in software." % [table[0], score[0]])
                return
            else:
                if table_obj.final_points.size() < table_size:
                    table_obj.final_points.resize(table_size)
                    table_obj.final_points.fill(0)

                if data_store.tournament.settings.shuugi and table_obj.final_shuugi.size() < table_size:
                    table_obj.final_shuugi.resize(table_size)
                    table_obj.final_shuugi.fill(0)

                if table_obj.penalties.size() < table_size:
                    table_obj.penalties.resize(table_size)
                    table_obj.penalties.fill(0)

                table_obj.final_points[player_index] = score[1]
                if data_store.tournament.settings.shuugi:
                    table_obj.final_shuugi[player_index] = score[2]
                    table_obj.penalties[player_index] = score[3]
                else:
                    table_obj.penalties[player_index] = score[2]
                
    _show_message("Scores successfully imported from spreadsheet.")
    
    data_store.recalculate_scores()

func _show_message(error_message):
    error_label.text = error_message
    error_block.visible = true
    control_block.visible = false

func _construct_export_payload():
    var payload = {}
    payload["valueInputOption"] = "USER_ENTERED"
    
extends Control
class_name TournamentSettingsPreview

var tournament : Tournament = null

@onready var tournament_name : Label = $HBoxContainer/SettingsPreview/TournamentName/Label

@onready var game_type : SettingDisplay = $HBoxContainer/SettingsPreview/GameType
@onready var uma_type : SettingDisplay = $HBoxContainer/SettingsPreview/UmaType

@onready var fixed_uma : UmaDisplay = $HBoxContainer/SettingsPreview/FixedUma

@onready var floating_uma_1 : UmaDisplay = $HBoxContainer/SettingsPreview/FloatingUma1
@onready var floating_uma_2 : UmaDisplay = $HBoxContainer/SettingsPreview/FloatingUma2
@onready var floating_uma_3 : UmaDisplay = $HBoxContainer/SettingsPreview/FloatingUma3

@onready var tiebreak_strategy : SettingDisplay = $HBoxContainer/SettingsPreview/TiebreakStrategy

@onready var start_points : SettingDisplay = $HBoxContainer/SettingsPreview/StartPoints
@onready var return_points : SettingDisplay = $HBoxContainer/SettingsPreview/ReturnPoints

@onready var oka : UmaDisplay = $HBoxContainer/SettingsPreview/Oka

@onready var pairing_system : SettingDisplay = $HBoxContainer/SettingsPreview/PairingSystem

@onready var riichi_sticks : SettingDisplay = $HBoxContainer/SettingsPreview/RiichiSticks
@onready var generate_seat_winds : SettingDisplay = $HBoxContainer/SettingsPreview/GeneratePairings

@onready var time_per_round_minutes : SettingDisplay = $HBoxContainer/SettingsPreview/TimePerRound
@onready var score_per_thousand_points : SettingDisplay = $HBoxContainer/SettingsPreview/ScorePerThousand

@onready var start_shuugi : SettingDisplay = $HBoxContainer/SettingsPreview/StartShuugi
@onready var end_shuugi : SettingDisplay = $HBoxContainer/SettingsPreview/EndShuugi
@onready var score_per_shuugi : SettingDisplay = $HBoxContainer/SettingsPreview/ScorePerShuugi

@onready var player_table : Tree = $HBoxContainer/SettingsPreview/Players/MarginContainer/Tree

@onready var confirm_button : Button = $HBoxContainer/SettingsPreview/Controls/Confirm/Confirm
@onready var cancel_button : Button = $HBoxContainer/SettingsPreview/Controls/Cancel/Cancel

@onready var data_store = get_node("/root/DataStore")

var TournamentManager = preload("res://scene/tournament/tournament_management.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    confirm_button.pressed.connect(_handle_confirm)
    cancel_button.pressed.connect(_handle_cancel)

    render()

func init(new_tournament: Tournament):
    tournament = new_tournament

func render():
    tournament_name.text = tournament.name

    game_type.set_text("Game Type", tournament.settings.get_game_type_string())
    uma_type.set_text("Uma Type", tournament.settings.get_uma_type_string())

    if tournament.settings.uma_type == TournamentSettings.UmaType.FIXED:
        fixed_uma.set_values("Uma", tournament.settings.fixed_uma)
        floating_uma_1.visible = false
        floating_uma_2.visible = false
        floating_uma_3.visible = false
    else:
        fixed_uma.visible = false

        if tournament.settings.game_type == TournamentSettings.GameType.YONMA:
            floating_uma_1.set_values("Uma (0 or 2 Players >= Return)", tournament.settings.floating_uma_1)
            floating_uma_2.set_values("Uma (3 Players >= Return)", tournament.settings.floating_uma_2)
            floating_uma_3.set_values("Uma (1 Player >= Return)", tournament.settings.floating_uma_3)
        else:
            floating_uma_1.set_values("Uma (0 or 1 Player >= Return)", tournament.settings.floating_uma_1)
            floating_uma_2.set_values("Uma (2 Players >= Return)", tournament.settings.floating_uma_2)
            floating_uma_3.visible = false
    
    tiebreak_strategy.set_text("Tiebreak", tournament.settings.get_tiebreak_strategy_string())
    
    start_points.set_text("Start", str(tournament.settings.start_points))
    return_points.set_text("Return", str(tournament.settings.return_points))
    oka.set_values("Oka", tournament.settings.oka)

    pairing_system.set_text("Pairing System", tournament.settings.get_pairing_system_string())

    riichi_sticks.set_text("Riichi Sticks", tournament.settings.get_riichi_sticks_strategy_string())
    generate_seat_winds.set_text("Assign Seat Winds", tournament.settings.get_assign_seat_winds_string())

    time_per_round_minutes.set_text("Default Round Timer (Minutes)", str(tournament.settings.time_per_round_minutes))
    if tournament.settings.advanced_settings:
        score_per_thousand_points.set_text("Score Per 1000 Points", "%.2f" % tournament.settings.score_per_thousand_points)

        if tournament.settings.shuugi:
            start_shuugi.set_text("Starting Shuugi", str(tournament.settings.start_shuugi))
            end_shuugi.set_text("Ending Shuugi", str(tournament.settings.end_shuugi))
            score_per_shuugi.set_text("Score Per Shuugi", "%.2f" % tournament.settings.score_per_shuugi)
        else:
            start_shuugi.visible = false
            end_shuugi.visible = false
            score_per_shuugi.visible = false
    else:
        score_per_thousand_points.visible = false
        start_shuugi.visible = false
        end_shuugi.visible = false
        score_per_shuugi.visible = false

    for player in tournament.registered_players:
        var row = player_table.create_item()

        row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

        row.set_text(0, str(player.id))
        row.set_text(1, player.name)
        row.set_text(2, player.affiliation)

        row.set_editable(0, false)
        row.set_editable(1, false)
        row.set_editable(2, false)

func _handle_confirm():
    data_store.load_tournament(tournament)
    get_tree().change_scene_to_packed(TournamentManager)

func _handle_cancel():
    queue_free()

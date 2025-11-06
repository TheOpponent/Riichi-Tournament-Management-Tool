extends Control
class_name TournamentSetup

@onready var start_tournament_button : Button = $HBoxContainer/SettingsPane/VBoxContainer/MarginContainer/StartTournamentButton

@onready var tournament_name : LineEdit = $HBoxContainer/SettingsPane/TournamentNameContainer/HBoxContainer2/MarginContainer/TournamentName

@onready var game_type_dropdown : OptionButton = $HBoxContainer/SettingsPane/GameTypeContainer/HBoxContainer2/MarginContainer/GameType
@onready var uma_type_dropdown : OptionButton = $HBoxContainer/SettingsPane/UmaTypeContainer/HBoxContainer2/MarginContainer/UmaType

@onready var fixed_uma : UmaContainer = $HBoxContainer/SettingsPane/UmaContainer

@onready var floating_uma_1 : UmaContainer = $HBoxContainer/SettingsPane/UmaContainer1
@onready var floating_uma_2 : UmaContainer = $HBoxContainer/SettingsPane/UmaContainer2
@onready var floating_uma_3 : UmaContainer = $HBoxContainer/SettingsPane/UmaContainer3

@onready var tiebreak_dropdown : OptionButton = $HBoxContainer/SettingsPane/TiebreakContainer/HBoxContainer2/MarginContainer/TiebreakDropdown

@onready var start_value : NumericLineEdit = $HBoxContainer/SettingsPane/StartContainer/HBoxContainer2/MarginContainer/StartValue
@onready var return_value : NumericLineEdit = $HBoxContainer/SettingsPane/ReturnContainer/HBoxContainer2/MarginContainer/ReturnValue

@onready var oka : UmaContainer = $HBoxContainer/SettingsPane/OkaContainer

@onready var round_timer_mins : NumericLineEdit = $HBoxContainer/SettingsPane/RoundTimeContainer/HBoxContainer2/MarginContainer/RoundTimeValue

@onready var pairing_type : OptionButton = $HBoxContainer/SettingsPane/PairingTypeContainer/HBoxContainer2/MarginContainer/PairingTypeDropdown

@onready var assign_winds_button : CheckBox = $HBoxContainer/SettingsPane/AssignWindsContainer/HBoxContainer2/MarginContainer/AssignWindsButton

@onready var riichi_sticks_strategy : OptionButton = $HBoxContainer/SettingsPane/RiichiSticksContainer/HBoxContainer2/MarginContainer/RiichiSticksDropdown

@onready var advanced_settings_button : CheckButton = $HBoxContainer/SettingsPane/AdvancedSettingsButton/HBoxContainer2/MarginContainer/AdvancedSettingsButton
@onready var advanced_settings_container : VBoxContainer = $HBoxContainer/SettingsPane/AdvancedSettingsContainer

@onready var score_per_thousand : NumericLineEdit = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ScoreSettingContainer/HBoxContainer2/MarginContainer/ScoreSettingInput

@onready var shuugi_settings_button : CheckButton = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ShuugiSettingsButton/HBoxContainer2/MarginContainer/ShuugiSettingsButton
@onready var shuugi_settings_container : VBoxContainer = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ShuugiContainer

@onready var shuugi_start_value : NumericLineEdit = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ShuugiContainer/StartContainer/HBoxContainer2/MarginContainer/StartValue
@onready var shuugi_return_value : NumericLineEdit = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ShuugiContainer/ReturnContainer/HBoxContainer2/MarginContainer/ReturnValue
@onready var score_per_shuugi : NumericLineEdit = $HBoxContainer/SettingsPane/AdvancedSettingsContainer/ShuugiContainer/ScoreSettingContainer/HBoxContainer2/MarginContainer/ScoreSettingInput

@onready var players_pane : PlayersInputPane = $HBoxContainer/PlayersPane

var TournamentSettingsPreviewScene = preload("res://scene/setup/tournament_settings_preview.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    start_tournament_button.pressed.connect(_start_tournament)

    game_type_dropdown.item_selected.connect(_switch_game_type)
    uma_type_dropdown.item_selected.connect(_switch_uma_type)

    fixed_uma.set_defaults([30, 10, -10, -30])

    floating_uma_1.set_defaults([15, 5, -5, -15])
    floating_uma_2.set_defaults([15, 5, 0, -20])
    floating_uma_3.set_defaults([20, 0, -5, -15])

    floating_uma_1.set_title("Uma (0 or 2 Players >= Return)")
    floating_uma_2.set_title("Uma (3 Players >= Return)")
    floating_uma_3.set_title("Uma (1 Player >= Return)")

    oka.set_title("Oka")

    advanced_settings_button.toggled.connect(_toggle_advanced_settings)

    shuugi_settings_button.toggled.connect(_toggle_shuugi)

func _switch_game_type(selected : int):
    if selected == 0:
        fixed_uma.set_player_count(4)
        floating_uma_1.set_player_count(4)
        floating_uma_2.set_player_count(4)
        floating_uma_3.set_player_count(4)

        fixed_uma.set_defaults([30, 10, -10, -30])

        floating_uma_1.set_defaults([15, 5, -5, -15])
        floating_uma_2.set_defaults([15, 5, 0, -20])
        floating_uma_3.set_defaults([20, 0, -5, -15])

        floating_uma_1.set_title("Uma (0 or 2 or 4 Players >= Return)")
        floating_uma_2.set_title("Uma (3 Players >= Return)")
        floating_uma_3.set_title("Uma (1 Player >= Return)")

        floating_uma_3.visible = true
    else:
        fixed_uma.set_player_count(3)
        floating_uma_1.set_player_count(3)
        floating_uma_2.set_player_count(3)
        floating_uma_3.set_player_count(3)

        fixed_uma.set_defaults([30, 0, -30])

        floating_uma_1.set_defaults([30, 0, -30])
        floating_uma_2.set_defaults([20, 10, -30])

        floating_uma_1.set_title("Uma (0 or 1 or 3 Players >= Return)")
        floating_uma_2.set_title("Uma (2 Players >= Return)")

        floating_uma_3.visible = false

func _switch_uma_type(selected : int):
    if selected == 0:
        fixed_uma.visible = true
        floating_uma_1.visible = false
        floating_uma_2.visible = false
        floating_uma_3.visible = false
    else:
        fixed_uma.visible = false
        floating_uma_1.visible = true
        floating_uma_2.visible = true
        if game_type_dropdown.selected == 0:
            floating_uma_3.visible = true
        else:
            floating_uma_3.visible = false

func _toggle_advanced_settings(toggled : bool):
    if toggled:
        advanced_settings_container.visible = true
    else:
        advanced_settings_container.visible = false

func _toggle_shuugi(toggled : bool):
    if toggled:
        shuugi_settings_container.visible = true
    else:
        shuugi_settings_container.visible = false

func _start_tournament():
    var tournament = Tournament.new()
    var tournament_settings = tournament.settings

    tournament.name = tournament_name.text
    
    tournament_settings.game_type = game_type_dropdown.selected
    tournament_settings.uma_type = uma_type_dropdown.selected

    if uma_type_dropdown.selected == 0:
        tournament_settings.fixed_uma = fixed_uma.export()
    else:
        tournament_settings.floating_uma_1 = floating_uma_1.export()
        tournament_settings.floating_uma_2 = floating_uma_2.export()
        if game_type_dropdown.selected == 0:
            tournament_settings.floating_uma_3 = floating_uma_3.export()
    
    tournament_settings.tiebreak_strategy = tiebreak_dropdown.selected
    
    tournament_settings.start_points = start_value.get_value()
    tournament_settings.return_points = return_value.get_value()

    tournament_settings.oka = oka.export()

    tournament_settings.time_per_round_minutes = round_timer_mins.get_value()
    tournament_settings.pairing_system = pairing_type.selected

    tournament_settings.assign_seat_winds = assign_winds_button.button_pressed
    tournament_settings.riichi_sticks_strategy = riichi_sticks_strategy.selected

    if advanced_settings_button.button_pressed:
        tournament_settings.advanced_settings = true
        tournament_settings.score_per_thousand_points = score_per_thousand.get_value()

        if shuugi_settings_button.button_pressed:
            tournament_settings.shuugi = true
            tournament_settings.start_shuugi = shuugi_start_value.get_value()
            tournament_settings.end_shuugi = shuugi_return_value.get_value()
            tournament_settings.score_per_shuugi = score_per_shuugi.get_value()
        else:
            tournament_settings.shuugi = false
    else:
        tournament_settings.advanced_settings = false
        tournament_settings.shuugi = false

    tournament.registered_players = players_pane.export()
    
    var preview_scene = TournamentSettingsPreviewScene.instantiate()
    preview_scene.init(tournament)

    get_tree().root.add_child(preview_scene)
    

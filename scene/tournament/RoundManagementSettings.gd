extends VBoxContainer
class_name RoundManagementSettings

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var active_tables : Label = $ActiveTables/Right/Label
@onready var duplicate_pairings : CheckBox = $AvoidDuplicates/Right/CheckBox
@onready var round_time : NumericLineEdit = $RoundTime/Right/NumericLineEdit
@onready var assign_winds : CheckBox = $AssignWinds/Right/CheckBox
@onready var assign_subs : CheckBox = $LeftoverPlayers/Right/CheckBox
@onready var swiss_blocks : NumericLineEdit = $SwissBlocks/Right/NumericLineEdit

@onready var active_tables_container : HBoxContainer = $ActiveTables
@onready var swiss_blocks_container : HBoxContainer = $SwissBlocks

func _ready():
    render()

    active_tables.modulate = Color(1, 0, 0, 1)

    data_store.players_updated.connect(_on_update)
    data_store.standings_updated.connect(_on_update)

func render():
    var settings = data_store.tournament.settings

    var active_tables_count = data_store.get_active_tables_count()
    if active_tables_count > 0: 
        active_tables_container.visible = true
        active_tables.text = str(active_tables_count)
    else:
        active_tables_container.visible = false

    duplicate_pairings.button_pressed = true

    round_time.text = str(settings.time_per_round_minutes)
    round_time.placeholder_text = str(settings.time_per_round_minutes)

    assign_winds.button_pressed = settings.assign_seat_winds

    assign_subs.button_pressed = true

func get_settings() -> RoundPairingSettings:
    var settings = RoundPairingSettings.new()
    settings.avoid_duplicates = duplicate_pairings.button_pressed
    settings.time_per_round_minutes = int(round_time.text)
    settings.assign_seat_winds = assign_winds.button_pressed
    settings.assign_subs = assign_subs.button_pressed
    settings.swiss_blocks = swiss_blocks.get_value()

    return settings
    
func _on_update():
    render()

class RoundPairingSettings:
    var avoid_duplicates : bool = true
    var time_per_round_minutes : int = 60
    var assign_seat_winds : bool = true
    var assign_subs : bool = true
    var swiss_blocks : int = 0

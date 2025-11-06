extends HBoxContainer
class_name PlayerManagement

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var active_players : PlayerList = $ActivePlayersContainer/ActivePlayersListContainer/ActivePlayers

@onready var transfer_left : Button = $ButtonsContainer/MoveLeftButton
@onready var transfer_right : Button = $ButtonsContainer/MoveRightButton

@onready var inactive_players : InactivePlayerList = $InactivePlayersContainer/InactivePlayersListContainer/InactivePlayers
@onready var edit_players_button : Button = $InactivePlayersContainer/EditPlayersButton
@onready var add_players_button : Button = $InactivePlayersContainer/AddPlayersButton

var edit_enabled = false

func _ready():
    transfer_left.pressed.connect(_on_activate_player_pressed)
    transfer_right.pressed.connect(_on_deactivate_player_pressed)

    edit_players_button.pressed.connect(_on_edit_players_pressed)
    add_players_button.pressed.connect(_on_add_players_pressed)

func _on_activate_player_pressed():
    var id = inactive_players.selected_id()
    if id != 0:
        data_store.activate_player(id)

func _on_deactivate_player_pressed():
    var id = active_players.selected_id()
    if id != 0:
        data_store.deactivate_player(id)

func _on_edit_players_pressed():
    if not edit_enabled:
        edit_enabled = true
        inactive_players.enable_edit()
        add_players_button.visible = true
        edit_players_button.text = "Done"
    else:
        edit_enabled = false
        inactive_players.disable_edit()
        add_players_button.visible = false
        edit_players_button.text = "Edit Players"

func _on_add_players_pressed():
    inactive_players.create_player(_next_id())

func _next_id() -> int:
    var max_id = 0
    for player_id in data_store.players_by_id:
        if player_id > max_id:
            max_id = player_id
    return max_id + 1

extends HBoxContainer
class_name TournamentStandings

@onready var player_table : PlayerList = $PlayerListContainer/PlayerList
@onready var hanchan_table : PlayerHanchanHistory = $PlayerHanchanHistoryContainer/PlayerHanchanHistory

@onready var data_store = get_node("/root/DataStore")

# Called when the node enters the scene tree for the first time.
func _ready():
    data_store.standings_updated.connect(_on_standings_updated)
    player_table.item_selected.connect(_on_player_selected)
    player_table.player_deselected.connect(_on_player_selected)

func render() -> void:
    render_players()
    render_hanchan()

func render_players() -> void:
    player_table.render_players()

func render_hanchan() -> void:
    hanchan_table.render()

func _on_standings_updated() -> void:
    render()

func _on_player_selected() -> void:
    hanchan_table.inspect_player(player_table.selected_id())
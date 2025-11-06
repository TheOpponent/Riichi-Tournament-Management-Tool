extends HBoxContainer
class_name RoundManagement

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var pairings_pane : VBoxContainer = $PairingsContainer
@onready var pairings_tree : PairingsList = $PairingsContainer/PairingsListContainer/PairingsList
@onready var players_pane : VBoxContainer = $ActivePlayersContainer

@onready var duplicates_pane : VBoxContainer = $ControlsContainer/ManageDuplicates
@onready var duplicates_label : RichTextLabel = $ControlsContainer/ManageDuplicates/MarginContainer/Label
@onready var reshuffle_button : Button = $ControlsContainer/ManageDuplicates/Button

@onready var confirm_pane : HBoxContainer = $ControlsContainer/ConfirmRound
@onready var confirm_pairings_button : Button = $ControlsContainer/ConfirmRound/ConfirmPairingsButton
@onready var cancel_button : Button = $ControlsContainer/ConfirmRound/CancelRoundButton

@onready var settings_pane : RoundManagementSettings = $ControlsContainer/Settings
@onready var create_pairings_button : Button = $ControlsContainer/Settings/CreatePairingsButton
@onready var start_round_button : Button = $ControlsContainer/Settings/StartRoundButton

var duplicate_message_template : String = "There are [color=red]%d[/color] tables with duplicate pairings."
var generating_message_template : String = "Generating pairings (%d attempts)..."

func _ready():
    create_pairings_button.pressed.connect(_on_create_pairings)

    reshuffle_button.pressed.connect(_on_reshuffle)

    cancel_button.pressed.connect(_on_cancel)
    confirm_pairings_button.pressed.connect(_on_accept_pairing)

    start_round_button.pressed.connect(_on_start_round)

func _on_create_pairings() -> void:
    _create_pairings()
    
    pairings_pane.visible = true
    players_pane.visible = false

    settings_pane.visible = false
    confirm_pane.visible = true
    create_pairings_button.visible = false

func _on_reshuffle():
    _create_pairings()

func _create_pairings():
    var pairing_settings : RoundManagementSettings.RoundPairingSettings = settings_pane.get_settings()

    var selected_pairings = []
    var selected_byes = []
    var min_duplicates = 100000

    var attempts = 0

    while attempts < 100:
        randomize()

        var generated_pairings = _create_swiss_pairings(pairing_settings)
        
        var pairings = generated_pairings[0]
        var byes = generated_pairings[1]

        var duplicate_count = 0

        if pairing_settings.avoid_duplicates:
            var prior_pairings : Dictionary = _prior_pairings()
            for pairing in pairings:
                if _pairing_has_duplicate(pairing, prior_pairings):
                    duplicate_count += 1
            if duplicate_count < min_duplicates:
                selected_pairings = pairings
                selected_byes = byes
                min_duplicates = duplicate_count
        else:
            selected_pairings = pairings
            selected_byes = byes
            min_duplicates = 0

        if min_duplicates == 0:
            break
        
        attempts += 1

    if pairing_settings.avoid_duplicates:
        if min_duplicates > 0:
            duplicates_label.text = duplicate_message_template % min_duplicates
            duplicates_pane.visible = true
        else:
            duplicates_pane.visible = false

    var tables = _pairings_to_tables(pairing_settings, selected_pairings)

    pairings_tree.render(tables, selected_byes)

func _on_cancel():
    _reset_ui()

func _on_accept_pairing():
    data_store.add_round(pairings_tree.export_tables())

    _reset_ui()

func _on_start_round():
    var pairing_settings : RoundManagementSettings.RoundPairingSettings = settings_pane.get_settings()
    data_store.start_round(pairing_settings.time_per_round_minutes * 60)

func _reset_ui():
    pairings_pane.visible = false
    players_pane.visible = true

    duplicates_pane.visible = false

    settings_pane.visible = true
    confirm_pane.visible = false
    create_pairings_button.visible = true

func _create_random_pairings(pairing_settings : RoundManagementSettings.RoundPairingSettings):
    var player_objects = data_store.tournament.registered_players.duplicate()
    var players = []

    for player in player_objects:
        players.append(player.id)

    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var byes = []

    if pairing_settings.assign_subs and players.size() % table_size != 0:
        var subs_needed = table_size - (players.size() % table_size)
        for i in range(subs_needed):
            players.append(0)
    else:
        var byes_num = players.size() % table_size
        players.shuffle()

        byes.append_array(players.slice(players.size() - byes_num))

        players.resize(players.size() - byes_num)

    var pairings = _create_pairings_for_block(pairing_settings, players)

    return [pairings, byes]
    
func _create_swiss_pairings(pairing_settings : RoundManagementSettings.RoundPairingSettings):
    var player_objects = data_store.tournament.registered_players.duplicate()

    var players = []
    var scores = data_store.get_scores()

    for player in player_objects:
        players.append(player.id)

    players.sort_custom(func(a, b): return scores.get(a, 0) > scores.get(b, 0))

    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var byes_num = players.size() % table_size

    var byes = []

    if pairing_settings.assign_subs and byes_num != 0:
        var subs_needed = table_size - byes_num
        for i in range(subs_needed):
            players.append(0)
    else:
        byes.append_array(players.slice(players.size() - byes_num))
        players.resize(players.size() - byes_num)

    var tables_num = players.size() / table_size

    var tables_per_block = tables_num / pairing_settings.swiss_blocks
    var larger_blocks_left = 0
    if tables_num % pairing_settings.swiss_blocks != 0:
        tables_per_block += 1
        larger_blocks_left = tables_num % pairing_settings.swiss_blocks
    
    var pairings = []
    
    var start_index = 0
    for block in pairing_settings.swiss_blocks:
        var block_players = tables_per_block * table_size

        var block_tables = _create_pairings_for_block(
                pairing_settings, players.slice(start_index, start_index + block_players))

        start_index += block_players

        pairings.append_array(block_tables)

        if larger_blocks_left > 0:
            larger_blocks_left -= 1
            if larger_blocks_left == 0:
                tables_per_block -= 1

    return [pairings, byes]

func _create_pairings_for_block(pairing_settings, players):
    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var pairings = []

    players.shuffle()

    if pairing_settings.avoid_duplicates:
        var prior_pairings : Dictionary = _prior_pairings()
        
        # We don't actually guarantee that there aren't duplicates, but for events where the
        # number of rounds is small relative to the number of players this is good enough
        while players.size() > 0:
            var next_player = players.pop_front()
            var next_players = []
            next_players.append(next_player)
            var has_played = {}
            if prior_pairings.has(next_player):
                has_played.merge(prior_pairings[next_player])

            var index = 0
            # TODO: change the way this array is getting modified?
            while index < players.size():
                if not has_played.has(players[index]):
                    next_players.append(players[index])
                    if prior_pairings.has(players[index]):
                        has_played.merge(prior_pairings[players[index]])
                    players.remove_at(index)
                    index -= 1
                if next_players.size() == table_size:
                    break
                index += 1
            
            while next_players.size() < table_size:
                next_players.append(players.pop_front())
            pairings.append(next_players)
        
        for pairing in pairings:
            pairing.sort()

        _gej(pairings)

        for pairing in pairings:
            pairing.shuffle()
    else:
        var index = 0
        while index < players.size():
            var next_players = []
            next_players.append(players[index])
            next_players.append(players[index + 1])
            next_players.append(players[index + 2])
            if table_size == 4:
                next_players.append(players[index + 3])
            pairings.append(next_players)
            index += table_size
    
    return pairings

func _gej(pairings):
    var prior_pairings : Dictionary = _prior_pairings()
    var costs : Dictionary = {}

    var duplicates = 0

    for pairing in pairings:
        if not costs.has(pairing):
            costs[pairing] = _pairing_cost(pairing, prior_pairings)
        if costs[pairing] > 0:
            duplicates += 1
    
    if duplicates == 0:
        return pairings

    var swaps = []
    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3
    for i in range(table_size):
        for j in range(table_size):
            for k in range(1, pairings.size()):
                swaps.append([i, j, k])
        
    for _attempt in range(30):
        pairings.sort_custom(func(a, b): return costs[a] > costs[b])

        var best_delta = 0
        var best_swap = []

        for swap in swaps:
            var prev_cost = _pairing_cost(pairings[0], prior_pairings) + _pairing_cost(pairings[swap[2]], prior_pairings)

            pairings = _apply_swap(pairings, swap)

            var new_cost = _pairing_cost(pairings[0], prior_pairings) + _pairing_cost(pairings[swap[2]], prior_pairings)

            if new_cost < prev_cost and prev_cost - new_cost > best_delta:
                best_delta = prev_cost - new_cost
                best_swap = swap
            
            pairings = _apply_swap(pairings, swap)
        
        if best_swap.is_empty():
            return
        pairings = _apply_swap(pairings, best_swap)
        pairings[0].sort()
        pairings[best_swap[2]].sort()

        duplicates = 0
        for pairing in pairings:
            if not costs.has(pairing):
                costs[pairing] = _pairing_cost(pairing, prior_pairings)
            if costs[pairing] > 0:
                duplicates += 1
        if duplicates == 0:
            return

func _apply_swap(pairings, swap):
    var temp_id = pairings[0][swap[0]]
    pairings[0][swap[0]] = pairings[swap[2]][swap[1]]
    pairings[swap[2]][swap[1]] = temp_id

    return pairings

func _pairings_to_tables(pairing_settings, pairings):
    var table_size = 4 if data_store.tournament.settings.game_type == TournamentSettings.GameType.YONMA else 3

    var tables = []
    for pairing in pairings:
        var next_table = Table.new()

        next_table.player_ids.append_array(pairing)
        
        if pairing_settings.assign_seat_winds:
            next_table.player_seats.append(Table.Wind.EAST)
            next_table.player_seats.append(Table.Wind.SOUTH)
            next_table.player_seats.append(Table.Wind.WEST)
            if table_size == 4:
                next_table.player_seats.append(Table.Wind.NORTH)
        
        tables.append(next_table)
    
    return tables

func _pairing_cost(pairing, prior_pairings):
    var seen = {}
    var cost = 0
    for player in pairing:
        if seen.has(player):
            cost += 1
        if prior_pairings.has(player):
            seen.merge(prior_pairings[player])
    return cost

func _pairing_has_duplicate(pairing, prior_pairings):
    var seen = {}
    for player in pairing:
        if seen.has(player):
            return true
        if prior_pairings.has(player):
            seen.merge(prior_pairings[player])
    return false

func _prior_pairings():
    var prior_pairings : Dictionary = {}
    for table in data_store.tournament.tables:
        for player_id in table.player_ids:
            if not prior_pairings.has(player_id):
                prior_pairings[player_id] = {}
            
            for opponent in table.player_ids:
                if (opponent != player_id
                        and not prior_pairings[player_id].has(opponent)):
                    prior_pairings[player_id][opponent] = true
    return prior_pairings
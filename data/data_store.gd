extends Node

var tournament : Tournament = Tournament.new()

var players_by_id : Dictionary = {}

var scores : Dictionary = {}

signal standings_updated
signal players_updated
signal round_start

func start_round(time_secs : float):
    round_start.emit(time_secs)

func add_single_table(new_table : Table) -> void:
    tournament.tables.append(new_table)
    standings_updated.emit()

func add_round(new_tables) -> void:
    for table in new_tables:
        table.round_id = tournament.next_round
    tournament.next_round += 1
    tournament.tables.append_array(new_tables)
    standings_updated.emit()

func update_table(new_table : Table) -> void:
    var updated_table = get_table(new_table.round_id, new_table.table_id)

    updated_table.player_ids = new_table.player_ids
    updated_table.player_seats = new_table.player_seats

    updated_table.final_points = new_table.final_points
    updated_table.final_shuugi = new_table.final_shuugi
    updated_table.penalties = new_table.penalties

    updated_table.left_over_kyotaku = new_table.left_over_kyotaku

    recalculate_scores()

func recalculate_scores() -> void:
    scores = tournament.calculate_scores()
    standings_updated.emit()
    players_updated.emit()

func update_inactive_players(new_inactive_players : Array) -> void:
    for player in tournament.inactive_players:
        if players_by_id.has(player.id):
            players_by_id.erase(player.id)
    tournament.inactive_players = new_inactive_players
    for player in tournament.inactive_players:
        players_by_id[player.id] = player

func activate_player(player_id : int) -> void:
    tournament.inactive_players = tournament.inactive_players.filter(func find_player(player):
        return player.id != player_id)
    tournament.registered_players.append(players_by_id[player_id])
    tournament.registered_players.sort_custom(func comp(a, b):
        return a.id < b.id)
    players_updated.emit()

func deactivate_player(player_id : int) -> void:
    tournament.registered_players = tournament.registered_players.filter(func find_player(player):
        return player.id != player_id)
    tournament.inactive_players.append(players_by_id[player_id])
    tournament.inactive_players.sort_custom(func comp(a, b):
        return a.id < b.id)
    players_updated.emit()

func get_scores() -> Dictionary:
    return scores

func get_hanchan_history() -> Array:
    return tournament.tables

func get_hanchan_history_for_player(player_id : int) -> Array:
    var relevant_tables = []
    for table in tournament.tables:
        if table.player_ids.has(player_id):
            relevant_tables.append(table)
    return relevant_tables

func get_table(round_id : int, table_id : int) -> Table:
    for table in tournament.tables:
        if table.round_id == round_id and table.table_id == table_id:
            return table
    return null

func get_round(round_id : int) -> Array[Table]:
    var tables : Array[Table] = []
    for table in tournament.tables:
        if table.round_id == round_id:
            tables.append(table)
    tables.sort_custom(func comp(a, b): return a.table_id < b.table_id)
    return tables

func get_player(player_id : int) -> Player:
    if player_id == 0:
        var sub = Player.new()
        sub.id = 0
        sub.name = "Substitute Player"
        sub.affiliation = "Independent"
        return sub
    return players_by_id[player_id]

func get_player_name(player_id : int) -> String:
    if player_id == 0:
        return "Substitute Player"
    return players_by_id[player_id].name

func get_active_tables_count() -> int:
    var tables = tournament.tables
    var count = 0
    for table in tables:
        if not table.is_complete(tournament.settings):
            count += 1
    return count

func get_next_table_id(round_id : int) -> int:
    var tables = tournament.tables
    var max_id = 0
    for table in tables:
        if table.round_id == round_id and table.table_id > max_id:
            max_id = table.table_id
    return max_id + 1

func load_tournament(new_tournament : Tournament) -> void:
    tournament = new_tournament

    players_by_id = {}

    for player in tournament.registered_players:
        players_by_id[player.id] = player
    
    for player in tournament.inactive_players:
        players_by_id[player.id] = player
    
    scores = tournament.calculate_scores()

    get_window().title = tournament.name

func load_from_dict(data : Dictionary) -> void:
    var new_tournament = Tournament.new()
    new_tournament.deserialize(data)
    load_tournament(new_tournament)

func create_cut(cut : Cut) -> bool:
    tournament.cuts.append(cut)
    scores = tournament.calculate_scores()

    # Save the list of players before the cut if we need to redo tiebreakers
    # at some point
    var most_recent_cut = tournament.cuts[tournament.cuts.size() - 1]
    for player in tournament.registered_players:
        most_recent_cut.tiebreak_priority.append(player.id)

    standings_updated.emit()
    players_updated.emit()

    return tournament.registered_players.size() != cut.player_count

func delete_cut(index : int) -> void:
    tournament.cuts.remove_at(index)
    scores = tournament.calculate_scores()

    standings_updated.emit()
    players_updated.emit()

func score_format(score) -> String:
    var has_non_integer = not _is_int(tournament.settings.score_per_thousand_points) or (
        tournament.settings.shuugi and not _is_int(tournament.settings.score_per_shuugi)
    )

    if not has_non_integer:
        if score >= 0:
            return "%.1f"
        else:
            return "(%.1f)"
    else:
        if score >= 0:
            return "%.2f"
        else:
            return "(%.2f)"

func _is_int(val) -> bool:
    return is_equal_approx(abs(val - int(val)), 0)
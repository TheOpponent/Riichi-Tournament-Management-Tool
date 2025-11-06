class_name Tournament

var name : String = ""
var registered_players : Array[Player] = []
var inactive_players : Array[Player] = []
var settings : TournamentSettings = TournamentSettings.new()
var tables : Array[Table] = []
var cuts : Array[Cut] = []

var next_round : int = 1

func serialize() -> Dictionary:
    var serialized = {
        "name": name,
        "registered_players": [],
        "inactive_players": [],
        "settings": settings.serialize(),
        "tables": [],
        "cuts": [],
        "next_round": next_round
    }

    for player in registered_players:
        serialized["registered_players"].append(player.serialize())

    for player in inactive_players:
        serialized["inactive_players"].append(player.serialize())

    for table in tables:
        serialized["tables"].append(table.serialize())

    for cut in cuts:
        serialized["cuts"].append(cut.serialize())

    return serialized

func deserialize(data : Dictionary):
    name = data["name"]
    next_round = data["next_round"]
    settings = TournamentSettings.new()
    settings.deserialize(data["settings"])

    for player_data in data["registered_players"]:
        var new_player = Player.new()
        new_player.deserialize(player_data)
        registered_players.append(new_player)

    for player_data in data["inactive_players"]:
        var inactive_player = Player.new()
        inactive_player.deserialize(player_data)
        inactive_players.append(inactive_player)

    for table_data in data["tables"]:
        var table = Table.new()
        table.deserialize(table_data)
        tables.append(table)

    for cut_data in data["cuts"]:
        var cut = Cut.new()
        cut.deserialize(cut_data)
        cuts.append(cut)

func calculate_scores() -> Dictionary:
    var scores = {}

    var all_tables = tables.duplicate()

    if cuts.size() > 0:
        registered_players.append_array(inactive_players)
        inactive_players = []

    for cut in cuts:
        var deleted_indices = []
        for index in range(all_tables.size()):
            if cut.start_round <= all_tables[index].round_id and all_tables[index].round_id <= cut.end_round:
                deleted_indices.append(index)

                var table_scores = all_tables[index].score_table(settings)
                for player in table_scores:
                    scores[player] = scores.get(player, 0) + table_scores[player]
        
        deleted_indices.sort()
        deleted_indices.reverse()
        for index in deleted_indices:
            all_tables.remove_at(index)
        
        var cut_scores = []

        for player in registered_players:
            cut_scores.append(scores[player.id])
        
        if cut_scores.size() <= cut.player_count:
            continue

        cut_scores.sort()
        cut_scores.reverse()
        
        var post_cut_ids = []
        
        var has_tie = false
        var tied_score = 0

        if cut_scores[cut.player_count - 1] == cut_scores[cut.player_count]:
            has_tie = true
            tied_score = cut_scores[cut.player_count - 1]
        
        cut_scores.resize(cut.player_count)

        var tied_ids = []

        for player in registered_players:
            if cut_scores.has(scores[player.id]) and (not has_tie or scores[player.id] > tied_score):
                post_cut_ids.append(player.id)
            elif has_tie and scores[player.id] == tied_score:
                tied_ids.append(player.id)
        
        var tie_index = 0
        while post_cut_ids.size() < cut.player_count and tied_ids.size() > 0 and tie_index < tied_ids.size():
            if cut.tiebreak_priority.has(tied_ids[tie_index]):
                post_cut_ids.append(tied_ids[tie_index])
                tied_ids.remove_at(tie_index)
            else:
                tie_index += 1
        
        if post_cut_ids.size() < cut.player_count:
            post_cut_ids.append_array(tied_ids)
        
        var registered_index = 0
        while registered_index < registered_players.size():
            if not post_cut_ids.has(registered_players[registered_index].id):
                inactive_players.append(registered_players[registered_index])
                registered_players.remove_at(registered_index)
            else:
                registered_index += 1
        
        if cut.score_modification != Cut.ScoreModification.NONE:
            for score in scores:
                if cut.score_modification == Cut.ScoreModification.HALVED:
                    scores[score] = scores[score] / 2
                elif cut.score_modification == Cut.ScoreModification.ZERO:
                    scores[score] = 0
        
    for table in all_tables:
        var table_scores = table.score_table(settings)
        for player in table_scores:
            scores[player] = scores.get(player, 0) + table_scores[player]

    return scores

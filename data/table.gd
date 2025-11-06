class_name Table

enum Wind { EAST, SOUTH, WEST, NORTH }

var table_id : int = 0
var round_id : int = 0
var cut_id : int = -1

var player_ids = []
var player_seats = []

var final_points = []
var final_shuugi = []
var penalties = []

var left_over_kyotaku : float = 0

func serialize() -> Dictionary:
    var result = {
        "table_id": table_id,
        "round_id": round_id,
        "cut_id": cut_id,
        "player_ids": player_ids,
        "player_seats": player_seats,
        "final_points": final_points,
        "final_shuugi": final_shuugi,
        "penalties": penalties,
        "left_over_kyotaku": left_over_kyotaku
    }
    return result

func deserialize(data : Dictionary):
    table_id = data["table_id"]
    round_id = data["round_id"]
    cut_id = data["cut_id"]
    player_ids = data["player_ids"]
    player_seats = data["player_seats"]
    final_points = data["final_points"]
    final_shuugi = data["final_shuugi"]
    penalties = data["penalties"]
    left_over_kyotaku = data["left_over_kyotaku"]

func is_complete(settings : TournamentSettings) -> bool:
    var scores_complete = final_points.size() == player_ids.size()
    var shuugi_complete = final_shuugi.size() == player_ids.size()
    return scores_complete and (not settings.shuugi or shuugi_complete)

func player_index(player_id : int) -> int:
    for index in range(player_ids.size()):
        if player_ids[index] == player_id:
            return index
    return -1

func score_table_arr(settings : TournamentSettings) -> Array:
    var scores = []
    if not is_complete(settings):
        # Don't score games that aren't fully scored
        return scores

    var net = []

    # Calculate net score relative to return points
    var max_score = -100000
    var max_indices = []
    for score in final_points:
        var net_score = (score - settings.return_points) / 1000
        if net_score > max_score:
            max_score = net_score
        net.append(net_score)
    
    # Determine rankings and apply uma. Technically if someone scores under -100000 we could run into
    # issues here, but if that happens we have bigger problems to worry about.
    var first_score = -100000
    var first = []

    var second_score = -100000
    var second = []

    var third_score = -100000
    var third = []

    var fourth_score = -100000
    var fourth = []

    var at_or_above_start = 0

    for index in range(net.size()):
        if net[index] >= 0:
            at_or_above_start += 1

        if net[index] > first_score:
            # Shift all of the other rankings down by one
            fourth_score = third_score
            fourth = third

            third_score = second_score
            third = second

            second_score = first_score
            second = first

            first_score = net[index]
            first = [index]
        elif net[index] == first_score:
            first.append(index)
        elif net[index] > second_score:
            # Shift all of the other rankings down by one
            fourth_score = third_score
            fourth = third

            third_score = second_score
            third = second

            second_score = net[index]
            second = [index]
        elif net[index] == second_score:
            second.append(index)
        elif net[index] > third_score:
            # Shift all of the other rankings down by one
            fourth_score = third_score
            fourth = third

            third_score = net[index]
            third = [index]
        elif net[index] == third_score:
            third.append(index)
        else:
            fourth_score = net[index]
            fourth = [index]
    
    var post_uma_scores = []
    post_uma_scores.resize(net.size())

    var uma_applied = []
    
    if settings.uma_type == TournamentSettings.UmaType.FIXED:
        uma_applied = settings.fixed_uma
    elif settings.uma_type == TournamentSettings.UmaType.FLOATING:
        if settings.game_type == TournamentSettings.GameType.YONMA:
            if at_or_above_start == 4 or at_or_above_start == 2 or at_or_above_start == 0:
                uma_applied = settings.floating_uma_1
            elif at_or_above_start == 3:
                uma_applied = settings.floating_uma_2
            else:
                uma_applied = settings.floating_uma_3
        else:
            if at_or_above_start == 3 or at_or_above_start == 1 or at_or_above_start == 0:
                uma_applied = settings.floating_uma_1
            else:
                uma_applied = settings.floating_uma_2
    
    if settings.tiebreak_strategy == TournamentSettings.TiebreakStrategy.WIND_ORDER:
        var uma_index = 0
        if first.size() > 1:
            var uma_order = []
            
            var left = first.duplicate()
            for index in range(first.size()):
                var min_seat = 5
                var min_index = -1
                for pl_index in left:
                    if player_seats[pl_index] < min_seat:
                        min_seat = player_seats[pl_index]
                        min_index = pl_index
                uma_order.append(min_index)
                left.erase(min_index)
            
            for uma in uma_order:
                post_uma_scores[uma] = first_score + uma_applied[uma_index] + settings.oka[uma_index]
                uma_index += 1
        else:
            post_uma_scores[first[0]] = first_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1
        
        if second.size() > 1:
            var uma_order = []

            var left = second.duplicate()
            for index in range(second.size()):
                var min_seat = 5
                var min_index = -1
                for pl_index in left:
                    if player_seats[pl_index] < min_seat:
                        min_seat = player_seats[pl_index]
                        min_index = pl_index
                uma_order.append(min_index)
                left.erase(min_index)

            for uma in uma_order:
                post_uma_scores[uma] = second_score + uma_applied[uma_index] + settings.oka[uma_index]
                uma_index += 1
        elif second.size() != 0:
            post_uma_scores[second[0]] = second_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1
        
        if third.size() > 1:
            var uma_order = []
            # There can't be more than two people tied for third
            if player_seats[third[0]] < player_seats[third[1]]:
                uma_order.append(third[0])
                uma_order.append(third[1])
            else:
                uma_order.append(third[1])
                uma_order.append(third[0])
            
            for uma in uma_order:
                post_uma_scores[uma] = third_score + uma_applied[uma_index] + settings.oka[uma_index]
                uma_index += 1
        elif third.size() != 0:
            post_uma_scores[third[0]] = third_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1
        
        if fourth.size() != 0:
            post_uma_scores[fourth[0]] = fourth_score + uma_applied[uma_index] + settings.oka[uma_index]
    elif settings.tiebreak_strategy == TournamentSettings.TiebreakStrategy.SPLIT:
        var uma_index = 0
        if first.size() > 1:
            var cumulative_uma = 0
            var cumulative_oka = 0
            for player in range(first.size()):
                cumulative_uma += uma_applied[uma_index]
                cumulative_oka += settings.oka[uma_index]
                uma_index += 1
            
            if first.size() == 3 and (int(cumulative_uma) % 3 != 0 or int(cumulative_oka) % 3 != 0):
                var uma_remainder = float(int(cumulative_uma * 10) % 3) / 10
                var uma_divided = floor((cumulative_uma * 10) / 3) / 10
                var oka_remainder = float(int(cumulative_oka * 10) % 3) / 10
                var oka_divided = floor((cumulative_oka * 10) / 3) / 10
                for player in range(first.size()):
                    post_uma_scores[first[player]] = first_score + uma_divided + oka_divided

                var min_seat = 5
                var min_seat_index = -1
                for index in first:
                    if player_seats[index] < min_seat:
                        min_seat = player_seats[index]
                        min_seat_index = index
                post_uma_scores[min_seat_index] += uma_remainder + oka_remainder
            else:
                for player in range(first.size()):
                    post_uma_scores[first[player]] = first_score + (cumulative_uma / first.size()) + (cumulative_oka / first.size())
        else:
            post_uma_scores[first[0]] = first_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1

        if second.size() > 1:
            var cumulative_uma = 0
            var cumulative_oka = 0
            for player in range(second.size()):
                cumulative_uma += uma_applied[uma_index]
                cumulative_oka += settings.oka[uma_index]
                uma_index += 1

            if second.size() == 3 and (int(cumulative_uma) % 3 != 0 or int(cumulative_oka) % 3 != 0):
                var uma_remainder = float(int(cumulative_uma * 10) % 3) / 10
                var uma_divided = cumulative_uma * 10 / 3
                var oka_remainder = float(int(cumulative_oka * 10) % 3) / 10
                var oka_divided = floor((cumulative_oka * 10) / 3) / 10

                # Special case handling for negative uma remainders
                if cumulative_uma < 0:
                    uma_divided = ceil(uma_divided) / 10
                    uma_remainder += 0.3
                    uma_divided -= 0.1
                else:
                    uma_divided = floor(uma_divided) / 10

                for player in range(second.size()):
                    post_uma_scores[second[player]] = second_score + uma_divided + oka_divided

                var min_seat = 5
                var min_seat_index = -1
                for index in second:
                    if player_seats[index] < min_seat:
                        min_seat = player_seats[index]
                        min_seat_index = index
                post_uma_scores[min_seat_index] += uma_remainder + oka_remainder
            else:
                for player in range(second.size()):
                    post_uma_scores[second[player]] = second_score + (cumulative_uma / second.size()) + (cumulative_oka / first.size())
        elif second.size() != 0:
            post_uma_scores[second[0]] = second_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1

        if third.size() > 1:
            var cumulative_uma = 0
            var cumulative_oka = 0
            for player in range(third.size()):
                cumulative_uma += uma_applied[uma_index]
                cumulative_oka += settings.oka[uma_index]
                uma_index += 1

            for player in range(third.size()):
                post_uma_scores[third[player]] = third_score + (cumulative_uma / third.size()) + (cumulative_oka / first.size())
        elif third.size() != 0:
            post_uma_scores[third[0]] = third_score + uma_applied[uma_index] + settings.oka[uma_index]
            uma_index += 1
        
        if fourth.size() != 0:
            post_uma_scores[fourth[0]] = fourth_score + uma_applied[uma_index] + settings.oka[uma_index]

    # Adjust for kyotaku based on settings
    if settings.riichi_sticks_strategy == TournamentSettings.RiichiSticksStrategy.FIRST:
        for index in range(net.size()):
            if net[index] == max_score:
                max_indices.append(index)
        
        var min_seat = 5
        var min_seat_index = -1
        for index in max_indices:
            if player_seats[index] < min_seat:
                min_seat = player_seats[index]
                min_seat_index = index

        if settings.tiebreak_strategy == TournamentSettings.TiebreakStrategy.WIND_ORDER:
            post_uma_scores[min_seat_index] += left_over_kyotaku
        else:
            if max_indices.size() == 3 and int(left_over_kyotaku) % 3 != 0:
                for index in range(net.size()):
                    if net[index] == max_score:
                        post_uma_scores[index] += left_over_kyotaku * 0.3
                post_uma_scores[min_seat_index] += left_over_kyotaku * 0.1
            else:
                for index in range(net.size()):
                    if net[index] == max_score:
                        post_uma_scores[index] += left_over_kyotaku / max_indices.size()
    
    var scores_per_thousand = []
    for score in post_uma_scores:
        scores_per_thousand.append(score * settings.score_per_thousand_points)

    # Apply penalties
    var scores_post_penalties = scores_per_thousand.duplicate()
    for index in range(scores_post_penalties.size()):
        scores_post_penalties[index] -= penalties[index]

    if settings.shuugi:
        var shuugi_scores = []
        for index in range(scores_post_penalties.size()):
            shuugi_scores.append(scores_post_penalties[index] + ((final_shuugi[index] - settings.end_shuugi) * settings.score_per_shuugi))
        for index in range(shuugi_scores.size()):
            scores.append(shuugi_scores[index])
    else:
        for index in range(scores_post_penalties.size()):
            scores.append(scores_post_penalties[index])

    return scores

func score_table(settings : TournamentSettings) -> Dictionary:
    if not is_complete(settings):
        # Don't score games that aren't fully scored
        return {}

    var scores = score_table_arr(settings)
    var result = {}
    for index in range(player_ids.size()):
        result[player_ids[index]] = scores[index]
    return result
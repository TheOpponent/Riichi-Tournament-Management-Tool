class_name TournamentSettings

enum GameType { YONMA, SANMA }
enum UmaType { FIXED, FLOATING }
enum PairingSystem { RANDOM, PROGRESSIVE_SWISS }
enum TiebreakStrategy { WIND_ORDER, SPLIT }
enum RiichiSticksStrategy { LOST, FIRST }

var game_type : GameType = GameType.YONMA

var uma_type : UmaType = UmaType.FIXED

var fixed_uma = [30.0, 10.0, -10.0, -30.0]

var floating_uma_1 = [15.0, 5.0, -5.0, -15.0]
var floating_uma_2 = [15.0, 5.0, 0.0, -20.0]
# Unused if the game type is yonma
var floating_uma_3 = [20.0, 0.0, -5.0, -15.0]

var tiebreak_strategy : TiebreakStrategy = TiebreakStrategy.WIND_ORDER

var start_points : float = 25000
var return_points : float = 30000
var oka = [20, 0, 0, 0]
var pairing_system : PairingSystem = PairingSystem.RANDOM
var time_per_round_minutes : float = 75

var assign_seat_winds : bool = true

var riichi_sticks_strategy : RiichiSticksStrategy = RiichiSticksStrategy.LOST

var advanced_settings : bool = false

var score_per_thousand_points : float = 1.0

var shuugi : bool = false
var start_shuugi : float = 10
var end_shuugi : float = 10
var score_per_shuugi : float = 0.5

var script_id : String = ""

func serialize() -> Dictionary:
    return {
        "game_type": game_type,
        "uma_type": uma_type,
        "fixed_uma": fixed_uma,
        "floating_uma_1": floating_uma_1,
        "floating_uma_2": floating_uma_2,
        "floating_uma_3": floating_uma_3,
        "tiebreak_strategy": tiebreak_strategy,
        "start_points": start_points,
        "return_points": return_points,
        "oka": oka,
        "pairing_system": pairing_system,
        "time_per_round_minutes": time_per_round_minutes,
        "assign_seat_winds": assign_seat_winds,
        "riichi_sticks_strategy": riichi_sticks_strategy,
        "advanced_settings": advanced_settings,
        "score_per_thousand_points": score_per_thousand_points,
        "shuugi": shuugi,
        "start_shuugi": start_shuugi,
        "end_shuugi": end_shuugi,
        "score_per_shuugi": score_per_shuugi,
        "script_id": script_id
    }

func deserialize(data : Dictionary):
    game_type = data["game_type"]
    uma_type = data["uma_type"]
    fixed_uma = data["fixed_uma"]
    floating_uma_1 = data["floating_uma_1"]
    floating_uma_2 = data["floating_uma_2"]
    floating_uma_3 = data["floating_uma_3"]
    tiebreak_strategy = data["tiebreak_strategy"]
    start_points = data["start_points"]
    return_points = data["return_points"]
    oka = data["oka"]
    pairing_system = data["pairing_system"]
    time_per_round_minutes = data["time_per_round_minutes"]
    assign_seat_winds = data["assign_seat_winds"]
    riichi_sticks_strategy = data["riichi_sticks_strategy"]
    advanced_settings = data["advanced_settings"]
    score_per_thousand_points = data["score_per_thousand_points"]
    shuugi = data["shuugi"]
    start_shuugi = data["start_shuugi"]
    end_shuugi = data["end_shuugi"]
    score_per_shuugi = data["score_per_shuugi"]
    script_id = data.get("script_id", "")

func get_game_type_string() -> String:
    match game_type:
        GameType.YONMA:
            return "Yonma"
        GameType.SANMA:
            return "Sanma"
        _:
            return "Unknown"

func get_uma_type_string() -> String:
    match uma_type:
        UmaType.FIXED:
            return "Fixed"
        UmaType.FLOATING:
            return "Floating"
        _:
            return "Unknown"

func get_tiebreak_strategy_string() -> String:
    match tiebreak_strategy:
        TiebreakStrategy.WIND_ORDER:
            return "Wind Order"
        TiebreakStrategy.SPLIT:
            return "Split"
        _:
            return "Unknown"

func get_pairing_system_string() -> String:
    match pairing_system:
        PairingSystem.RANDOM:
            return "Random"
        PairingSystem.PROGRESSIVE_SWISS:
            return "Progressive Swiss"
        _:
            return "Unknown"

func get_assign_seat_winds_string() -> String:
    if assign_seat_winds:
        return "Yes"
    else:
        return "No"

func get_riichi_sticks_strategy_string() -> String:
    match riichi_sticks_strategy:
        RiichiSticksStrategy.LOST:
            return "Lost"
        RiichiSticksStrategy.FIRST:
            return "First"
        _:
            return "Unknown"

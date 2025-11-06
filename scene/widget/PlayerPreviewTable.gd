extends Tree
class_name PlayerPreviewTable

# Called when the node enters the scene tree for the first time.
func _ready():
    set_column_title(0, "Player ID")
    set_column_title(1, "Player Name")
    set_column_title(2, "Affiliation")

    set_column_custom_minimum_width(0, 0)
    set_column_custom_minimum_width(1, 500)
    set_column_custom_minimum_width(2, 300)

    # Initialize with a root
    create_item()

func export() -> Array[Player]:
    var players : Array[Player] = []
    for child in get_root().get_children():
        var player = Player.new()
        player.id = int(child.get_text(0))
        player.name = child.get_text(1)
        player.affiliation = child.get_text(2)
        players.append(player)
    return players

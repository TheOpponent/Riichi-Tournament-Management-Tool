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

## Check if a name already exists in the Tree. If the name exists, returns the same name with a 
## unique number appended, otherwise returns the same name unchanged.
func check_duplicate_name(name: String) -> String:
    var new_name := name
    var counter := 1
    var names = get_root().get_children()
    print(names)
    for i in names:
        if new_name == i.get_text(1):
            new_name = name + " %s" % counter
            counter += 1

    return new_name
    
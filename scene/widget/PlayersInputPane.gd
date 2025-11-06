extends VBoxContainer
class_name PlayersInputPane

@onready var player_table : PlayerPreviewTable = $MarginContainer/PlayerTable
@onready var text_input : TextEdit = $MarginContainer/TextEdit

@onready var add_player_button : Button = $HBoxContainer/AddPlayerContainer/AddPlayerButton
@onready var import_player_button : Button = $HBoxContainer/BulkAddContainer/BulkAddButton

# Called when the node enters the scene tree for the first time.
func _ready():
    add_player_button.pressed.connect(_add_player_button_pressed)
    import_player_button.pressed.connect(_import_players)

func _add_player_button_pressed():
    if player_table.visible == true:
        var row = player_table.create_item()

        row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
        row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

        row.set_text(0, str(player_table.get_root().get_child_count()))
        row.set_text(1, "Freed Jyanshi %d" % [player_table.get_root().get_child_count()])
        row.set_text(2, "Riichi Nomi NYC")

        row.set_editable(0, false)
        row.set_editable(1, true)
        row.set_editable(2, true)
    else:
        var csv = text_input.text
        var lines = csv.split("\n")
        for line in lines:
            if line == "":
                continue
            var tokens = line.split(",")
            var row = player_table.create_item()

            row.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
            row.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
            row.set_cell_mode(2, TreeItem.CELL_MODE_STRING)

            row.set_text(0, str(player_table.get_root().get_child_count()))
            row.set_text(1, tokens[0])
            row.set_text(2, tokens[1] if tokens.size() >= 2 else "")

            row.set_editable(0, false)
            row.set_editable(1, true)
            row.set_editable(2, true)

        text_input.text = ""

        add_player_button.text = "Add Player"
        import_player_button.visible = true

        player_table.visible = true
        text_input.visible = false

func _import_players():
    add_player_button.text = "Import Players"
    import_player_button.visible = false

    player_table.visible = false
    text_input.visible = true

    text_input.grab_focus()

func export() -> Array[Player]:
    return player_table.export()
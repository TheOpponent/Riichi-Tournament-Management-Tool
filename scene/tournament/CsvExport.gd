extends VBoxContainer
class_name CsvExport

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var view_selector : OptionButton = $OptionButton
@onready var text_box : TextEdit = $CsvBox
@onready var close_button : Button = $DoneCopying

signal done_exporting

func _ready():
    close_button.pressed.connect(_on_close_pressed)

    data_store.standings_updated.connect(render)
    data_store.players_updated.connect(render)

    view_selector.item_selected.connect(item_selected)

    render()

func reset():
    text_box.text = ""
    view_selector.select(0)
    render()

func item_selected(_index):
    render()

func render():
    if view_selector.get_selected_id() == 0:
        var string = "ID,Name,Affiliation\n"
        for player in data_store.tournament.registered_players:
            string += "%d,%s,%s\n" % [player.id, player.name, player.affiliation]
        for player in data_store.tournament.inactive_players:
            string += "%d,%s,%s\n" % [player.id, player.name, player.affiliation]
        text_box.text = string
    elif view_selector.get_selected_id() == 1:
        var string = "Round ID,Table ID,Player ID,Seat Wind,Points,Penalties"
        if data_store.tournament.settings.shuugi:
            string += ",Shuugi"
        string += "\n"
        for table in data_store.tournament.tables:
            for index in range(table.player_ids.size()):
                string += "%d,%d,%d" % [table.round_id, table.table_id, table.player_ids[index]]
                if table.is_complete(data_store.tournament.settings):
                    string += ",%d,%d,%d" % [
                        table.player_seats[index],
                        table.final_points[index],
                        table.penalties[index]]
                    if data_store.tournament.settings.shuugi:
                        string += ",%d" % table.final_shuugi[index]
                string += "\n"
        text_box.text = string

func _on_close_pressed():
    done_exporting.emit()
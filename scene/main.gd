extends Control

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var new_tournament_button : Button = $HBoxContainer/CenterContainer/NewTournamentButton
@onready var load_tournament_button : Button = $HBoxContainer/CenterContainer/LoadTournamentButton

@onready var file_dialog : FileDialog = $FileDialog

var TournamentManagerScene = preload("res://scene/tournament/tournament_management.tscn")
var TournamentSettingsScene = preload("res://scene/setup/tournament_settings.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
    new_tournament_button.pressed.connect(_configure_tournament)
    load_tournament_button.pressed.connect(_load_tournament)

    file_dialog.set_filters(PackedStringArray(["*.tmnt ; Tournament File"]))
    file_dialog.file_selected.connect(_load_file)


func _configure_tournament():
    get_tree().change_scene_to_packed(TournamentSettingsScene)

func _load_tournament():
    file_dialog.popup()

func _load_file(path : String):
    var save_file = FileAccess.open(path, FileAccess.READ)
    var data = save_file.get_var()
    data_store.load_from_dict(data)
    save_file.close()
    get_tree().change_scene_to_packed(TournamentManagerScene)
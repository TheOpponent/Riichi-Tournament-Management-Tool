extends HBoxContainer
class_name TournamentManagement

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var create_cut_button : Button = $Controls/CutButton
@onready var manage_cuts_button : Button = $Controls/ManageCutsButton
@onready var google_sheets_button : Button = $Controls/GoogleSheetsButton
@onready var save_button : Button = $Controls/SaveButton
@onready var export_csv_button : Button = $Controls/ExportCsvButton

@onready var cut_manager : CutManagement = $RightPane/CutManagement
@onready var cut_creator : CutCreation = $RightPane/CutCreation
@onready var sheets_manager : GoogleSheetsHandler = $RightPane/GoogleSheetsManagement
@onready var csv_viewer : CsvExport = $RightPane/CsvExport

@onready var file_dialog : FileDialog = $FileDialog


## Show a page `target` and hide all other pages.
func show_page(target):
    var windows = [cut_manager,cut_creator,sheets_manager,csv_viewer]
    windows.erase(target)

    for i in windows:
        i.visible = false
    target.visible = true

func _ready():
    create_cut_button.pressed.connect(_on_create_cut)
    manage_cuts_button.pressed.connect(_on_manage_cuts)
    google_sheets_button.pressed.connect(_on_manage_sheets)
    save_button.pressed.connect(_on_save)
    export_csv_button.pressed.connect(_on_export_csv)

    cut_manager.cut_manager_exit.connect(_on_manage_cuts_exit)
    cut_manager.delete_cut.connect(_on_delete_cut)

    cut_creator.cut_creation_finished.connect(_on_create_cut_exit)

    csv_viewer.done_exporting.connect(_on_csv_export_exit)

    sheets_manager.hide_sheets_handler.connect(_on_manage_sheets_exit)

    file_dialog.set_filters(PackedStringArray(["*.tmnt ; Tournament File"]))
    file_dialog.file_selected.connect(_save_file)

func _on_create_cut():
    show_page(cut_creator)

func _on_create_cut_exit():
    cut_creator.visible = false

func _on_manage_cuts():
    show_page(cut_manager)

func _on_delete_cut(cut_id : int):
    data_store.delete_cut(cut_id)

func _on_manage_cuts_exit():
    cut_manager.visible = false

func _on_manage_sheets():
    show_page(sheets_manager)

func _on_manage_sheets_exit():
    sheets_manager.visible = false

func _on_save():
    file_dialog.popup()
    var file_name = data_store.tournament.name.to_snake_case() + ".tmnt"
    file_dialog.current_file = file_name

func _save_file(path : String) -> void:
    var save_file = FileAccess.open(path, FileAccess.WRITE)
    save_file.store_var(data_store.tournament.serialize())
    save_file.close()

func _on_export_csv():
    show_page(csv_viewer)
    csv_viewer.reset()

func _on_csv_export_exit():
    csv_viewer.visible = false

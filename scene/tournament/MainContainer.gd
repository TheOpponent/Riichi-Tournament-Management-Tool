extends TabContainer
class_name MainContainer


func _ready():
    current_tab = 0
    set_tab_title(1, "Hanchan History")
    set_tab_title(2, "Round Management")
    set_tab_title(3, "Player Management")
    set_tab_title(4, "Tournament Management")
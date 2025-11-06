extends MarginContainer
class_name CountdownTimer

@onready var data_store : DataStore = get_node("/root/DataStore")

@onready var timer : Timer = $Timer
@onready var label : Button = $Time

var timed_out = false
var color_time_remaining = 0
var next_color = Color(1, 0, 0, 1)

func _ready():
    timer.timeout.connect(_on_timeout)
    label.pressed.connect(_on_timer_pressed)

    data_store.round_start.connect(start_timer)

func _process(delta):
    if not timer.is_stopped():
        label.text = secs_to_string(timer.time_left)
    
    if timed_out:
        color_time_remaining -= delta
        if color_time_remaining <= 0:
            color_time_remaining = 0.5
            label.modulate = next_color
            next_color = Color(1, 1, 1, 1) if next_color == Color(1, 0, 0, 1) else Color(1, 0, 0, 1)

func start_timer(time_sec : float):
    if time_sec != 0:
        _on_timer_pressed()
        timer.start(time_sec)
        label.text = secs_to_string(time_sec)

func secs_to_string(total_secs : float) -> String:
    var secs_int = floori(total_secs)
    var hours = secs_int / 3600
    var mins = (secs_int - hours * 3600) / 60
    var secs = secs_int % 60
    return "%02d:%02d:%02d" % [hours, mins, secs]

func _on_timeout():
    timer.stop()
    timed_out = true
    color_time_remaining = 0.5
    label.text = "00:00:00"

func _on_timer_pressed():
    if timed_out:
        timed_out = false
        label.text = "--:--:--"
        label.modulate = Color(1, 1, 1, 1)
        next_color = Color(1, 0, 0, 1)
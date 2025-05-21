@tool
class_name DialogPotrait
extends Sprite2D

@onready var audio_stream_player: AudioStreamPlayer = $"../AudioStreamPlayer"

var blink : bool = false : set = _set_blink
var open_mouth : bool = false : set = _set_open_mouth
var mouth_open_timer : int = 0 
var audio_pitch : float = 1.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	DialogSystem.letter_added.connect(_on_letter_added)
	blinker()

func _on_letter_added(char: String) -> void:
	if "aeiouy1234567890".contains(char.to_lower()):
		open_mouth = true	
		mouth_open_timer = 3
		audio_stream_player.pitch_scale= randf_range(audio_pitch - 0.04,audio_pitch + 0.04)
		audio_stream_player.play()
	elif ".,!?".contains(char):
		mouth_open_timer = 0

func _process(_delta: float) -> void:
	if mouth_open_timer > 0:
		mouth_open_timer -= 1
		open_mouth = true
	else:
		open_mouth = false

func update_potrait() -> void:
	if open_mouth:
		frame = 2
	else:
		frame = 0
		
	if blink == true:
		frame +=1
		
func blinker() -> void :
	if blink == false:
		await get_tree().create_timer(randf_range(0.1,3.1)).timeout
	else:
		await get_tree().create_timer(0.16).timeout
	blink =!blink
	blinker()


func _set_blink(val: bool) -> void:
	if blink != val:
		blink = val
		update_potrait()



func _set_open_mouth(val: bool) -> void:
	if open_mouth != val:
		open_mouth = val
		update_potrait()

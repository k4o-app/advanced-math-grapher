@tool
extends TextEdit

class_name AutoResizeTextEdit

var min_height := 60 
var max_height := 300
var user_resized := false


signal function_confirmed(new_text: String)

func _ready():
	text_changed.connect(_on_text_changed)
	focus_exited.connect(_on_focus_exited)
	focus_entered.connect(_on_focus_entered)
	
	# キー入力のハンドリング
	gui_input.connect(_on_gui_input)
	
	# サイズの設定を遅延させる
	call_deferred("set_custom_minimum_size", Vector2(0, min_height))
	call_deferred("adjust_height")

func _on_text_changed():
	adjust_height()


func adjust_height():
	var new_height = get_content_height() + 20  # 20はパディングの分
	new_height = clamp(new_height, min_height, max_height)
	custom_minimum_size.y = new_height
	size.y = new_height

func get_content_height() -> float:
	return get_line_count() * get_line_height()

func _on_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if event.shift_pressed:
				insert_text_at_caret("\n")
			else:
				emit_signal("function_confirmed", text)
			accept_event()

func _on_resize_handle_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				resizing_started()
			else:
				resizing_ended()
	elif event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			resizing(event)

func resizing_started():
	user_resized = true

func resizing_ended():
	user_resized = false
	adjust_height()

func resizing(event: InputEventMouseMotion):
	var new_height = size.y + event.relative.y
	new_height = clamp(new_height, min_height, max_height)
	custom_minimum_size.y = new_height
	size.y = new_height

func _on_focus_exited():
	emit_signal("function_confirmed", text)

func _on_focus_entered():
	adjust_height()

func set_text(new_text: String):
	text = new_text
	adjust_height()

@tool
extends TextEdit

class_name AutoResizeTextEdit

var min_height := 30
var max_height := 300
var user_resized := false
var resize_handle: ColorRect

signal formula_confirmed(new_text: String)

func _ready():
	text_changed.connect(_on_text_changed)
	resized.connect(_on_resized)
	focus_exited.connect(_on_focus_exited)
	focus_entered.connect(_on_focus_entered)
	
	# キー入力のハンドリング
	gui_input.connect(_on_gui_input)
	
	# リサイズハンドルを追加
	resize_handle = ColorRect.new()
	resize_handle.color = Color(0.5, 0.5, 0.5, 0.5)  # 半透明のグレー
	resize_handle.custom_minimum_size = Vector2(0, 5)  # 高さを5ピクセルに設定
	resize_handle.mouse_default_cursor_shape = Control.CURSOR_VSIZE
	add_child(resize_handle)
	
	# リサイズハンドルを下端に配置
	resize_handle.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	resize_handle.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	resize_handle.gui_input.connect(_on_resize_handle_gui_input)
	
	# シンタックスハイライターを設定
	syntax_highlighter = load("res://addons/advanced_math_grapher/formula_editor/formula_syntax_highlighter.gd").new(self)

func _on_text_changed():
	adjust_height()

func _on_resized():
	resize_handle.size.y = 5  # リサイズハンドルの高さを維持

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
				emit_signal("formula_confirmed", text)
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
	emit_signal("formula_confirmed", text)

func _on_focus_entered():
	adjust_height()

func set_text(new_text: String):
	text = new_text
	adjust_height()

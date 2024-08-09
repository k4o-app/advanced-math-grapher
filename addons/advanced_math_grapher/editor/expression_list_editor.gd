@tool
extends EditorProperty

var expression_list_container: VBoxContainer
var add_button: Button
var updating = false
var scroll_container: ScrollContainer

func _init():
	# メインのVBoxContainerを作成
	expression_list_container = VBoxContainer.new()
	add_child(expression_list_container)
	
	# "Expression List" ラベルを追加
	var label = Label.new()
	label.text = "Expression List"
	expression_list_container.add_child(label)
	
	# ScrollContainerを作成し、VBoxContainerに追加
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size = Vector2(0, 200)  # 最小の高さを設定
	expression_list_container.add_child(scroll_container)
	
	# Add Expressionボタンを作成し、VBoxContainerに追加
	add_button = Button.new()
	add_button.text = "Add Expression"
	add_button.connect("pressed", Callable(self, "_on_add_expression"))
	expression_list_container.add_child(add_button)

func _ready():
	refresh_expression_list()

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	if new_value == null:
		new_value = []
	
	if updating:
		return
	
	updating = true
	refresh_expression_list()
	updating = false

func refresh_expression_list():
	for child in scroll_container.get_children():
		child.queue_free()
	
	var vbox = VBoxContainer.new()
	scroll_container.add_child(vbox)
	
	var expressions = get_edited_object()[get_edited_property()]
	if expressions == null:
		expressions = []
	
	for i in range(expressions.size()):
		var expression_editor = ExpressionEditor.new(i)
		expression_editor.connect("expression_changed", Callable(self, "_on_expression_changed"))
		expression_editor.connect("expression_removed", Callable(self, "_on_expression_removed"))
		vbox.add_child(expression_editor)
		expression_editor.set_expression(expressions[i])

func _on_add_expression():
	var expressions = get_edited_object()[get_edited_property()]
	if expressions == null:
		expressions = []
	
	expressions.append({
		"expression": "x",
		"type": "Function",
		"display_name": "New Expression",
		"line_color": Color.BLUE,
		"line_width": 2.0,
		"line_style": "Solid",
		"show_derivative": false,
		"show_integral": false,
		"visible": true
	})
	
	emit_changed(get_edited_property(), expressions)

func _on_expression_changed(index: int, new_expression: Dictionary):
	var expressions = get_edited_object()[get_edited_property()]
	expressions[index] = new_expression
	emit_changed(get_edited_property(), expressions)

func _on_expression_removed(index: int):
	var expressions = get_edited_object()[get_edited_property()]
	expressions.remove(index)
	emit_changed(get_edited_property(), expressions)

# ExpressionEditor class
class ExpressionEditor extends VBoxContainer:
	var index: int
	var expression_input: LineEdit
	var type_option: OptionButton
	var display_name_input: LineEdit
	var line_color_picker: ColorPickerButton
	var line_width_spin: SpinBox
	var line_style_option: OptionButton
	var show_derivative_check: CheckBox
	var show_integral_check: CheckBox
	var visible_check: CheckBox
	var remove_button: Button

	signal expression_changed(index: int, new_expression: Dictionary)
	signal expression_removed(index: int)

	func _init(expr_index: int):
		index = expr_index
		
		expression_input = LineEdit.new()
		expression_input.connect("text_changed", Callable(self, "_on_expression_input_changed"))
		add_child(expression_input)
		
		type_option = OptionButton.new()
		type_option.add_item("Function", 0)
		type_option.add_item("Parametric", 1)
		type_option.add_item("Implicit", 2)
		type_option.connect("item_selected", Callable(self, "_on_type_changed"))
		add_child(type_option)
		
		display_name_input = LineEdit.new()
		display_name_input.connect("text_changed", Callable(self, "_on_display_name_changed"))
		add_child(display_name_input)
		
		line_color_picker = ColorPickerButton.new()
		line_color_picker.connect("color_changed", Callable(self, "_on_line_color_changed"))
		add_child(line_color_picker)
		
		line_width_spin = SpinBox.new()
		line_width_spin.min_value = 0.1
		line_width_spin.max_value = 10.0
		line_width_spin.step = 0.1
		line_width_spin.connect("value_changed", Callable(self, "_on_line_width_changed"))
		add_child(line_width_spin)
		
		line_style_option = OptionButton.new()
		line_style_option.add_item("Solid", 0)
		line_style_option.add_item("Dashed", 1)
		line_style_option.add_item("Dotted", 2)
		line_style_option.connect("item_selected", Callable(self, "_on_line_style_changed"))
		add_child(line_style_option)
		
		show_derivative_check = CheckBox.new()
		show_derivative_check.text = "Show Derivative"
		show_derivative_check.connect("toggled", Callable(self, "_on_show_derivative_changed"))
		add_child(show_derivative_check)
		
		show_integral_check = CheckBox.new()
		show_integral_check.text = "Show Integral"
		show_integral_check.connect("toggled", Callable(self, "_on_show_integral_changed"))
		add_child(show_integral_check)
		
		visible_check = CheckBox.new()
		visible_check.text = "Visible"
		visible_check.connect("toggled", Callable(self, "_on_visible_changed"))
		add_child(visible_check)
		
		remove_button = Button.new()
		remove_button.text = "Remove"
		remove_button.connect("pressed", Callable(self, "_on_remove_pressed"))
		add_child(remove_button)

	func set_expression(expression: Dictionary):
		expression_input.text = expression.get("expression", "")
		type_option.select(type_option.get_item_index(expression.get("type", "Function")))
		display_name_input.text = expression.get("display_name", "")
		line_color_picker.color = expression.get("line_color", Color.BLUE)
		line_width_spin.value = expression.get("line_width", 2.0)
		line_style_option.select(line_style_option.get_item_index(expression.get("line_style", "Solid")))
		show_derivative_check.button_pressed = expression.get("show_derivative", false)
		show_integral_check.button_pressed = expression.get("show_integral", false)
		visible_check.button_pressed = expression.get("visible", true)

	func _on_expression_input_changed(new_text: String):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_type_changed(new_index: int):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_display_name_changed(new_text: String):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_line_color_changed(new_color: Color):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_line_width_changed(new_value: float):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_line_style_changed(new_index: int):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_show_derivative_changed(toggled: bool):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_show_integral_changed(toggled: bool):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_visible_changed(toggled: bool):
		emit_signal("expression_changed", index, get_current_expression())

	func _on_remove_pressed():
		emit_signal("expression_removed", index)

	func get_current_expression() -> Dictionary:
		return {
			"expression": expression_input.text,
			"type": type_option.get_item_text(type_option.selected),
			"display_name": display_name_input.text,
			"line_color": line_color_picker.color,
			"line_width": line_width_spin.value,
			"line_style": line_style_option.get_item_text(line_style_option.selected),
			"show_derivative": show_derivative_check.button_pressed,
			"show_integral": show_integral_check.button_pressed,
			"visible": visible_check.button_pressed
		}

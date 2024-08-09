@tool
extends EditorProperty

var main_container: VBoxContainer
var expression_list: VBoxContainer
var add_button: Button
var updating: bool = false

func _init():
	main_container = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Expression List"
	main_container.add_child(label)
	
	expression_list = VBoxContainer.new()
	main_container.add_child(expression_list)
	
	add_button = Button.new()
	add_button.text = "Add Function"
	add_button.connect("pressed", Callable(self, "_on_add_function"))
	main_container.add_child(add_button)
	
	add_child(main_container)
	set_bottom_editor(main_container)


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
	print("Refreshing expression list")
	for child in expression_list.get_children():
		child.queue_free()
	
	var expressions = get_edited_object()[get_edited_property()]
	if expressions == null:
		expressions = []
	
	for i in range(expressions.size()):
		var function_editor = FunctionEditor.new(i)
		function_editor.connect("function_changed", Callable(self, "_on_function_changed"))
		function_editor.connect("function_removed", Callable(self, "_on_function_removed"))
		expression_list.add_child(function_editor)
		function_editor.set_function(expressions[i])

	print("Expression list refreshed. New count:", expression_list.get_child_count())

	# インデックスを更新
	_update_indices()

func _update_indices():
	for i in range(expression_list.get_child_count()):
		var function_editor = expression_list.get_child(i)
		function_editor.update_index(i)
		
func _on_add_function():
	var expressions = get_edited_object()[get_edited_property()]
	if expressions == null:
		expressions = []
	
	expressions.append({
		"expression": "x",
		"line_color": Color.BLUE,
		"line_width": 2.0,
		"line_style": 0,
		"show_derivative": false,
		"show_integral": false,
		"visible": true
	})
	
	emit_changed(get_edited_property(), expressions)

func _on_function_changed(index: int, new_function: Dictionary):
	var expressions = get_edited_object()[get_edited_property()]
	expressions[index] = new_function
	emit_changed(get_edited_property(), expressions)

func _on_function_removed(index: int):
	print("_on_function_removed called with index:", index)
	var expressions = _get_edited_object()[_get_edited_property()]
	print("Current expressions:", expressions)
	if index >= 0 and index < expressions.size():
		expressions.remove_at(index)
		print("Expression removed. New expressions:", expressions)
		emit_changed(_get_edited_property(), expressions)
		refresh_expression_list()
	else:
		print("Invalid index:", index)

func _get_edited_object():
	return get_edited_object()

func _get_edited_property():
	return get_edited_property()

class FunctionEditor extends VBoxContainer:
	var index: int
	var index_label: Label
	var properties_container: VBoxContainer

	var expression_input: LineEdit
	var line_color_picker: ColorPickerButton
	var line_width_spin: SpinBox
	var line_style_option: OptionButton
	var show_derivative_check: CheckBox
	var show_integral_check: CheckBox
	var visible_check: CheckBox
	var remove_button: Button

	signal function_changed(index: int, new_function: Dictionary)
	signal function_removed(index: int)

	func _on_remove_pressed():
		print("Remove button pressed for index:", index)
		emit_signal("function_removed", index)

	func _init(func_index: int):
		index = func_index
		
		var hbox = HBoxContainer.new()
		add_child(hbox)
		
		# インデックス表示用のPanelContainer
		var index_panel = PanelContainer.new()
		index_panel.size_flags_vertical = SIZE_EXPAND_FILL
		index_panel.custom_minimum_size.x = 30
		hbox.add_child(index_panel)
		
		var index_centering = CenterContainer.new()
		index_panel.add_child(index_centering)
		
		index_label = Label.new()
		index_label.text = str(index)
		index_centering.add_child(index_label)
		
		# プロパティ用のVBoxContainer
		properties_container = VBoxContainer.new()
		properties_container.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(properties_container)
		
		_add_property("Expression", LineEdit.new(), "_on_expression_changed")
		_add_property("Line Color", ColorPickerButton.new(), "_on_color_changed")
		_add_property("Line Width", SpinBox.new(), "_on_width_changed")
		_add_property("Line Style", OptionButton.new(), "_on_style_changed")
		_add_property("Show Derivative", CheckBox.new(), "_on_show_derivative_changed")
		_add_property("Show Integral", CheckBox.new(), "_on_show_integral_changed")
		_add_property("Visible", CheckBox.new(), "_on_visible_changed")
		
		remove_button = Button.new()
		remove_button.text = "Remove Function"
		remove_button.connect("pressed", Callable(self, "_on_remove_pressed"))
		properties_container.add_child(remove_button)

	func _add_property(property_name: String, control: Control, signal_method: String):
		var hbox = HBoxContainer.new()
		properties_container.add_child(hbox)
		
		var label = Label.new()
		label.text = property_name + ":"
		label.custom_minimum_size.x = 120  # プロパティ名の幅を固定
		hbox.add_child(label)
		
		control.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(control)
		
		if control is LineEdit:
			expression_input = control
		elif control is ColorPickerButton:
			line_color_picker = control
		elif control is SpinBox:
			line_width_spin = control
			control.min_value = 0.1
			control.max_value = 10.0
			control.step = 0.1
		elif control is OptionButton:
			line_style_option = control
			control.add_item("Solid", 0)
			control.add_item("Dashed", 1)
			control.add_item("Dotted", 2)
		elif control is CheckBox:
			control.text = ""  # チェックボックスのテキストをクリア
			if property_name == "Show Derivative":
				show_derivative_check = control
			elif property_name == "Show Integral":
				show_integral_check = control
			elif property_name == "Visible":
				visible_check = control
		
		if signal_method:
			control.connect(control.get_signal_list()[0].name, Callable(self, signal_method))


	func update_index(new_index: int):
		index = new_index
		index_label.text = str(index)

	func set_function(function: Dictionary):
		expression_input.text = function.get("expression", "")
		line_color_picker.color = function.get("line_color", Color.BLUE)
		line_width_spin.value = function.get("line_width", 2.0)
		line_style_option.selected = function.get("line_style", 0)
		show_derivative_check.button_pressed = function.get("show_derivative", false)
		show_integral_check.button_pressed = function.get("show_integral", false)
		visible_check.button_pressed = function.get("visible", true)

	func _on_expression_changed(new_text: String):
		emit_signal("function_changed", index, get_current_function())

	func _on_color_changed(new_color: Color):
		emit_signal("function_changed", index, get_current_function())

	func _on_width_changed(new_value: float):
		emit_signal("function_changed", index, get_current_function())

	func _on_style_changed(new_index: int):
		emit_signal("function_changed", index, get_current_function())

	func _on_show_derivative_changed(toggled: bool):
		emit_signal("function_changed", index, get_current_function())

	func _on_show_integral_changed(toggled: bool):
		emit_signal("function_changed", index, get_current_function())

	func _on_visible_changed(toggled: bool):
		emit_signal("function_changed", index, get_current_function())

	func get_current_function() -> Dictionary:
		return {
			"expression": expression_input.text,
			"line_color": line_color_picker.color,
			"line_width": line_width_spin.value,
			"line_style": line_style_option.selected,
			"show_derivative": show_derivative_check.button_pressed,
			"show_integral": show_integral_check.button_pressed,
			"visible": visible_check.button_pressed
		}

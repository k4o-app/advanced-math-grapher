@tool
extends EditorProperty

const AdvancedMathGrapher = preload("res://addons/advanced_math_grapher/advanced_math_grapher.gd")

var formula_edit = LineEdit.new()
var expression_tree = Tree.new()
var updating = false
var current_expression: MathExpression

func _init():
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	formula_edit.connect("text_submitted", Callable(self, "_on_formula_submitted"))
	vbox.add_child(formula_edit)
	
	expression_tree.set_custom_minimum_size(Vector2(0, 200))
	expression_tree.connect("item_edited", Callable(self, "_on_item_edited"))
	vbox.add_child(expression_tree)

	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)

	_add_button(hbox, "Add", "_on_add_pressed")
	_add_button(hbox, "Edit", "_on_edit_pressed")
	_add_button(hbox, "Delete", "_on_delete_pressed")

func _add_button(parent: Control, text: String, callback: String):
	var button = Button.new()
	button.text = text
	button.connect("pressed", Callable(self, callback))
	parent.add_child(button)

func _on_formula_submitted(new_text):
	if updating:
		return
	emit_changed(get_edited_property(), new_text)
	_update_expression_tree(new_text)

func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	formula_edit.text = new_value
	_update_expression_tree(new_value)
	updating = false

func _update_expression_tree(formula):
	expression_tree.clear()
	var root = expression_tree.create_item()
	root.set_text(0, "Formula: " + formula)
	
	current_expression = get_edited_object().parse_formula(formula)
	if current_expression:
		_add_expression_to_tree(root, current_expression)

func _add_expression_to_tree(parent, expression):
	var item = expression_tree.create_item(parent)
	item.set_metadata(0, expression)
	
	match expression.get_class():
		"Constant":
			item.set_text(0, "定数: " + str(expression.value))
			item.set_editable(0, true)
		"Variable":
			item.set_text(0, "変数: " + expression.name)
			item.set_editable(0, true)
		"BinaryOperation":
			item.set_text(0, "演算: " + expression.operator)
			_add_expression_to_tree(item, expression.left)
			_add_expression_to_tree(item, expression.right)
		"Function":
			item.set_text(0, "関数: " + expression.name)
			_add_expression_to_tree(item, expression.argument)

func _on_item_edited():
	var item = expression_tree.get_edited()
	var expression = item.get_metadata(0)
	var new_text = item.get_text(0)
	
	match expression.get_class():
		"Constant":
			expression.value = float(new_text.split(": ")[1])
		"Variable":
			expression.name = new_text.split(": ")[1]
		"BinaryOperation":
			expression.operator = new_text.split(": ")[1]
		"Function":
			expression.name = new_text.split(": ")[1]
	
	_update_formula()

func _on_add_pressed():
	var item = expression_tree.get_selected()
	if item:
		var parent_expression = item.get_metadata(0)
		var new_expression = Constant.new(0)
		
		match parent_expression.get_class():
			"BinaryOperation":
				parent_expression.right = new_expression
			"Function":
				parent_expression.argument = new_expression
		
		_update_expression_tree(current_expression.to_formula())
		_update_formula()

func _on_edit_pressed():
	var item = expression_tree.get_selected()
	if item:
		item.set_editable(0, true)
		expression_tree.edit_selected()

func _on_delete_pressed():
	var item = expression_tree.get_selected()
	if item and item.get_parent() != expression_tree.get_root():
		var parent_item = item.get_parent()
		var parent_expression = parent_item.get_metadata(0)
		var child_expression = item.get_metadata(0)
		
		match parent_expression.get_class():
			"BinaryOperation":
				if parent_expression.left == child_expression:
					parent_expression.left = Constant.new(0)
				else:
					parent_expression.right = Constant.new(0)
			"Function":
				parent_expression.argument = Constant.new(0)
		
		_update_expression_tree(current_expression.to_formula())
		_update_formula()

func _update_formula():
	var new_formula = current_expression.to_formula()
	formula_edit.text = new_formula
	emit_changed(get_edited_property(), new_formula)

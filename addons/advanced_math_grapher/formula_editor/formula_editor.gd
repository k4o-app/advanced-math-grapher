@tool
extends EditorInspectorPlugin

const AdvancedMathGrapher = preload("res://addons/advanced_math_grapher/advanced_math_grapher.gd")
const FormulaParser = preload("res://addons/advanced_math_grapher/math/formula_parser.gd")
const FormulaTree = preload("res://addons/advanced_math_grapher/formula_editor/formula_tree.gd")

var formula_edit: LineEdit
var formula_tree: FormulaTree

func _can_handle(object):
	return object is AdvancedMathGrapher

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "formula":
		var vbox = VBoxContainer.new()
		vbox.set_custom_minimum_size(Vector2(0, 300))  # 全体の高さを増加
		
		formula_edit = LineEdit.new()
		formula_tree = FormulaTree.new()
		
		vbox.add_child(formula_edit)
		vbox.add_child(formula_tree)
		
		formula_edit.connect("text_submitted", Callable(self, "_on_formula_submitted").bind(object))
		formula_tree.connect("item_edited", Callable(self, "_on_item_edited").bind(object))
		
		add_custom_control(vbox)
		
		_update_formula_editor(object.formula)
		
		return true
	return false

func _update_formula_editor(formula: String):
	formula_edit.text = formula
	print("Updating formula editor with formula: ", formula)  # デバッグ出力
	var parser = FormulaParser.new()
	var expression = parser.parse_formula(formula)
	if expression:
		print("Parsed expression: ", expression.to_formula())  # デバッグ出力
		formula_tree.build_tree(expression)
	else:
		print("Failed to parse expression")  # デバッグ出力

func _on_formula_submitted(new_text: String, object):
	object.formula = new_text
	_update_formula_editor(new_text)

func _on_item_edited(object):
	var new_expression = formula_tree.get_expression()
	var new_formula = new_expression.to_formula()
	object.formula = new_formula
	formula_edit.text = new_formula

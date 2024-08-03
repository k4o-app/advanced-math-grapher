@tool
extends EditorInspectorPlugin

const AdvancedMathGrapher = preload("res://addons/advanced_math_grapher/core/advanced_math_grapher.gd")
const FormulaParser = preload("res://addons/advanced_math_grapher/math/formula_parser.gd")
const FormulaTree = preload("res://addons/advanced_math_grapher/formula_editor/formula_tree.gd")
const AutoResizeTextEdit = preload("res://addons/advanced_math_grapher/formula_editor/auto_resize_text_edit.gd")
const FormulaSyntaxHighlighter = preload("res://addons/advanced_math_grapher/formula_editor/formula_syntax_highlighter.gd")

var formula_edit: AutoResizeTextEdit
var formula_tree: FormulaTree

func _can_handle(object):
	return object is AdvancedMathGrapher

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "formula":
		var vbox = VBoxContainer.new()
		vbox.set_custom_minimum_size(Vector2(0, 300))  # 全体の高さを増加
		
		formula_edit = AutoResizeTextEdit.new()
		formula_edit.syntax_highlighter = FormulaSyntaxHighlighter.new(formula_edit)
		formula_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		formula_edit.custom_minimum_size.y = 60  # 初期の高さを設定
		formula_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # 横幅を最大に設定
		formula_tree = FormulaTree.new()
		
		vbox.add_child(formula_edit)
		vbox.add_child(formula_tree)
		
		formula_edit.formula_confirmed.connect(Callable(self, "_on_formula_confirmed").bind(object))
		formula_tree.connect("item_edited", Callable(self, "_on_item_edited").bind(object))
		
		add_custom_control(vbox)
		
		_update_formula_editor(object.formula)
		
		return true
	return false

func _update_formula_editor(formula: String):
	if formula_edit:
		formula_edit.text = formula
	if formula_tree:
		var parser = FormulaParser.new()
		var result = parser.parse_formula(formula)
		if result.expression:
			formula_tree.build_tree(result.expression)

func _on_formula_confirmed(new_text: String, object):
	object.formula = new_text
	_update_formula_editor(new_text)

func _on_item_edited(object):
	var new_expression = formula_tree.get_expression()
	if new_expression:
		var new_formula = new_expression.to_formula()
		object.formula = new_formula
		formula_edit.text = new_formula

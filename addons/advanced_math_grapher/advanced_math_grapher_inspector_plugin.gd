@tool
extends EditorInspectorPlugin

const AdvancedMathGrapher = preload("res://addons/advanced_math_grapher/core/advanced_math_grapher.gd")
const FunctionParser = preload("res://addons/advanced_math_grapher/math/function_parser.gd")
const AutoResizeTextEdit = preload("res://addons/advanced_math_grapher/editor/property_editors/auto_resize_text_edit.gd")
const FunctionSyntaxHighlighter = preload("res://addons/advanced_math_grapher/editor/syntax/function_syntax_highlighter.gd")

const ExpressionListEditor = preload("res://addons/advanced_math_grapher/editor/expression_list_editor.gd")

var function_edit: AutoResizeTextEdit

func _can_handle(object):
	return object is AdvancedMathGrapher

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	if name == "function":
		var vbox = VBoxContainer.new()
		vbox.set_custom_minimum_size(Vector2(0, 100))  # 全体の高さを増加
		
		function_edit = AutoResizeTextEdit.new()
		function_edit.syntax_highlighter = FunctionSyntaxHighlighter.new(function_edit)
		function_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
		function_edit.custom_minimum_size.y = 60  # 初期の高さを設定
		function_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # 横幅を最大に設定
		vbox.add_child(function_edit)

		function_edit.function_confirmed.connect(Callable(self, "_on_function_confirmed").bind(object))

		add_property_editor(name, vbox)
		_update_function_editor(object.function)

		return true
	if name == "expression_list":
		var editor = ExpressionListEditor.new()
		add_property_editor(name, editor)
		return true
	return false

func _update_function_editor(function: String):
	if function_edit:
		function_edit.text = function

func _on_function_confirmed(new_text: String, object):
	object.function = new_text
	_update_function_editor(new_text)


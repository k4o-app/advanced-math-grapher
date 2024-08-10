@tool
extends EditorInspectorPlugin

const ExpressionListEditor = preload("res://addons/advanced_math_grapher/editor/expression_list_editor.gd")

var function_edit: AutoResizeTextEdit

func _can_handle(object):
	return object is AdvancedMathGrapher

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
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


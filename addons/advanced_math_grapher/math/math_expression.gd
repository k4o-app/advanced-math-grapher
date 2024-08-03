class_name MathExpression
extends RefCounted

var comments: Array = []

func evaluate(variables: Dictionary) -> Variant:
	print("MathExpression.evaluate() called with variables: ", variables)  # デバッグ出力
	push_error("MathExpression.evaluate() is not implemented")
	return null

func to_formula() -> String:
	push_error("MathExpression.to_formula() is not implemented")
	return ""

func get_expression_type() -> String:
	return "MathExpression"

func get_children() -> Array[MathExpression]:
	return []

func set_comments(new_comments: Array):
	comments = new_comments

func get_comments() -> Array:
	return comments

func is_valid_result(result: Variant) -> bool:
	return result is float or result is int

func handle_invalid_result(result: Variant) -> Variant:
	if result is Array:
		push_error("Unexpected array result in expression evaluation")
	elif result == null:
		push_error("Null result in expression evaluation")
	else:
		push_error("Invalid result type in expression evaluation: " + str(typeof(result)))
	return null

class_name MathExpression
extends RefCounted

func evaluate(variables: Dictionary) -> Variant:
	push_error("MathExpression.evaluate() is not implemented")
	return null

func to_formula() -> String:
	push_error("MathExpression.to_formula() is not implemented")
	return ""

func get_expression_type() -> String:
	return "MathExpression"

func get_children() -> Array:
	return []


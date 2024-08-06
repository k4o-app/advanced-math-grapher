class_name ImplicitFunction
extends MathExpression

var expr: MathExpression

func _init(e: MathExpression):
	expr = e

func evaluate(variables: Dictionary) -> Variant:
	return expr.evaluate(variables)

func to_function() -> String:
	return expr.to_function() + " = 0"

func get_expression_type() -> String:
	return "ImplicitFunction"

func get_children() -> Array[MathExpression]:
	return [expr]


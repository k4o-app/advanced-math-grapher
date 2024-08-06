class_name ParametricFunction
extends MathExpression

var x_expr: MathExpression
var y_expr: MathExpression

func _init(x: MathExpression, y: MathExpression):
	x_expr = x
	y_expr = y

func evaluate(variables: Dictionary) -> Variant:
	return Vector2(x_expr.evaluate(variables), y_expr.evaluate(variables))

func to_function() -> String:
	return "(" + x_expr.to_function() + ", " + y_expr.to_function() + ")"

func get_expression_type() -> String:
	return "ParametricFunction"

func get_children() -> Array[MathExpression]:
	return [x_expr, y_expr]

class_name BinaryOperation
extends MathExpression

var left: MathExpression
var right: MathExpression
var operator: String

func _init(l: MathExpression, r: MathExpression, op: String):
	left = l
	right = r
	operator = op

func evaluate(variables: Dictionary) -> Variant:
	var l_val = left.evaluate(variables)
	var r_val = right.evaluate(variables)
	match operator:
		"+": return l_val + r_val
		"-": return l_val - r_val
		"*": return l_val * r_val
		"/": return l_val / r_val if r_val != 0 else INF
		"^": return pow(l_val, r_val)
	push_error("Unknown operator: " + operator)
	return 0.0

func to_formula() -> String:
	if left == null or right == null:
		return "Invalid Expression"
	return "(" + left.to_formula() + " " + operator + " " + right.to_formula() + ")"

func get_expression_type() -> String:
	return "BinaryOperation"
	
func get_children() -> Array:
	return [left, right] if left and right else []

	
func get_left() -> MathExpression:
	return left

func get_right() -> MathExpression:
	return right

func get_operator() -> String:
	return operator

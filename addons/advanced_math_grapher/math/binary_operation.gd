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
	var l_val = left.evaluate(variables) if left else null
	var r_val = right.evaluate(variables) if right else null
	
	if not is_valid_result(l_val) or not is_valid_result(r_val):
		push_error("Invalid operands for binary operation: " + str(l_val) + " " + operator + " " + str(r_val))
		return null
	
	match operator:
		"+": return l_val + r_val
		"-": return l_val - r_val
		"*": return l_val * r_val
		"/": 
			if r_val == 0:
				push_error("Division by zero")
				return INF
			return l_val / r_val
		"^": return pow(l_val, r_val)
	push_error("Unknown operator: " + operator)
	return null

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

func is_valid_result(result: Variant) -> bool:
	return result is float or result is int

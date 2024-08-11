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
	if left == null or right == null:
		push_error("Invalid BinaryOperation: left or right operand is null")
		return null

	var l_val = left.evaluate(variables)
	var r_val = right.evaluate(variables)
	
	if l_val == null or r_val == null:
		push_error("Invalid operands for binary operation: " + str(l_val) + " " + operator + " " + str(r_val))
		return null
	
	if not (l_val is float or l_val is int) or not (r_val is float or r_val is int):
		push_error("Invalid operand types for binary operation: " + str(typeof(l_val)) + " " + operator + " " + str(typeof(r_val)))
		return null
	
	var result
	match operator:
		"+": result = l_val + r_val
		"-": result = l_val - r_val
		"*": result = l_val * r_val
		"/": 
			if r_val == 0:
				push_error("Division by zero")
				return null
			result = l_val / r_val
		"^", "**": result = pow(l_val, r_val)
		_:
			push_error("Unknown operator: " + operator)
			return null
	
	return result

func to_function() -> String:
	if left == null or right == null:
		return "Invalid Expression"
	return "(" + left.to_function() + " " + operator + " " + right.to_function() + ")"

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

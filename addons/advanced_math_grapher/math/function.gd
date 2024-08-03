class_name Function
extends MathExpression

var name: String
var arguments: Array[MathExpression]

func _init(n: String, args: Array[MathExpression]):
	name = n
	arguments = args

func evaluate(variables: Dictionary) -> Variant:
	if arguments.is_empty():
		push_error("Function '" + name + "' called with no arguments")
		return null

	var arg_vals = []
	for arg in arguments:
		if arg == null:
			push_error("Null argument in function '" + name + "'")
			return null
		var val = arg.evaluate(variables)
		if val == null:
			push_error("Invalid argument for function '" + name + "': " + str(val))
			return null
		arg_vals.append(val)

	var result
	match name:
		"sin": result = sin(arg_vals[0]) if arg_vals[0] is float else null
		"cos": result = cos(arg_vals[0]) if arg_vals[0] is float else null
		"tan": result = tan(arg_vals[0]) if arg_vals[0] is float else null
		"exp": result = exp(arg_vals[0]) if arg_vals[0] is float else null
		"log": result = log(arg_vals[0]) if arg_vals[0] is float and arg_vals[0] > 0 else null
		"sqrt": result = sqrt(arg_vals[0]) if arg_vals[0] is float and arg_vals[0] >= 0 else null
		"sinh": result = sinh(arg_vals[0]) if arg_vals[0] is float else null
		"cosh": result = cosh(arg_vals[0]) if arg_vals[0] is float else null
		"tanh": result = tanh(arg_vals[0]) if arg_vals[0] is float else null
		"atan2": result = atan2(arg_vals[0], arg_vals[1]) if arg_vals[0] is float and arg_vals[1] is float else null
		"pow": result = pow(arg_vals[0], arg_vals[1]) if arg_vals[0] is float and arg_vals[1] is float else null
		_:
			push_error("Unknown function: " + name)
			return null
	
	return result

func to_formula() -> String:
	var args_str = ", ".join(arguments.map(func(arg): return arg.to_formula()))
	return name + "(" + args_str + ")"

func get_expression_type() -> String:
	return "Function"

func get_children() -> Array[MathExpression]:
	return arguments

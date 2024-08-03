class_name Function
extends MathExpression

var name: String
var arguments: Array[MathExpression]

func _init(n: String, args: Array[MathExpression]):
	name = n
	arguments = args
	print("Function initialized: ", name, " with ", arguments.size(), " arguments")

func evaluate(variables: Dictionary) -> Variant:
	var arg_vals = arguments.map(func(arg): return arg.evaluate(variables))
	match name:
		"sin": return sin(arg_vals[0])
		"cos": return cos(arg_vals[0])
		"tan": return tan(arg_vals[0])
		"exp": return exp(arg_vals[0])
		"log": return log(arg_vals[0]) if arg_vals[0] > 0 else -INF
		"sqrt": return sqrt(arg_vals[0]) if arg_vals[0] >= 0 else NAN
		"sinh": return sinh(arg_vals[0])
		"cosh": return cosh(arg_vals[0])
		"tanh": return tanh(arg_vals[0])
		"atan2": return atan2(arg_vals[0], arg_vals[1])
		"pow": return pow(arg_vals[0], arg_vals[1])
	push_error("Unknown function: " + name)
	return 0.0

func to_formula() -> String:
	var args_str = ", ".join(arguments.map(func(arg): return arg.to_formula()))
	return name + "(" + args_str + ")"

func get_expression_type() -> String:
	return "Function"

func get_children() -> Array[MathExpression]:
	return arguments

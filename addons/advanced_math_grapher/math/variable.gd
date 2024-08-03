class_name Variable
extends MathExpression

var name: String

func _init(n: String):
	name = n

func evaluate(variables: Dictionary) -> Variant:
	return variables.get(name, 0.0)

func to_formula() -> String:
	return name

func get_expression_type() -> String:
	return "Variable"

func get_children() -> Array:
	return []

class_name Constant
extends MathExpression

var value: float

func _init(v: float):
	value = v

func evaluate(_variables: Dictionary) -> Variant:
	return value

func to_function() -> String:
	return str(value)

func get_expression_type() -> String:
	return "Constant"

func get_children() -> Array:
	return []

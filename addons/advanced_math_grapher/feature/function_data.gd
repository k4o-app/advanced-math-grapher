class_name FunctionData
extends Resource

@export var function: String = "x"
@export var line_color: Color = Color.BLUE
@export var line_width: float = 2.0
@export var line_style: int = 0  # 0: solid, 1: dashed, 2: dotted

var parsed_expression: MathExpression

func _init(f: String = "x", color: Color = Color.BLUE, width: float = 2.0, style: int = 0):
	function = f
	line_color = color
	line_width = width
	line_style = style

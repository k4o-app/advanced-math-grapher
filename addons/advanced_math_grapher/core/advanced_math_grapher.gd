@tool
extends Control

class_name AdvancedMathGrapher

@export_group("Function")
## Enter a mathematical function. Use 'x' as the variable.
## Supported functions: sin, cos, tan, exp, log, sqrt
@export_multiline var function: String = "x" : set = set_function

@export var enable_multiple_functions: bool = false
@export var function_list: Array[String] = []
@export var expression_list: Array:
	get:
		return _expression_list
	set(new_list):
		_expression_list = new_list
		update_expressions()
var _expression_list: Array = []

@export_group("Graph Range")
@export var x_min: float = -10.0 : set = set_x_min
@export var x_max: float = 10.0 : set = set_x_max
@export var y_min: float = -10.0 : set = set_y_min
@export var y_max: float = 10.0 : set = set_y_max
@export var auto_adjust_range: bool = false

@export_group("Graph Style")
@export var line_color: Color = Color.BLUE : set = set_line_color
@export var line_width: float = 2.0 : set = set_line_width
@export var line_style: int = 0 : set = set_line_style  # 0: solid, 1: dashed, 2: dotted
@export var show_grid: bool = true
@export var grid_color: Color = Color(0.5, 0.5, 0.5, 0.5)
@export var axis_color: Color = Color.WHITE

@export_group("Interactivity")
@export var enable_zoom: bool = false
@export var enable_pan: bool = false
@export var show_value_on_hover: bool = false

@export_group("Animation")
@export var enable_animation: bool = false
@export var animation_speed: float = 1.0
@export var animation_parameter: String = "t"

@export_group("Advanced Features")
@export var show_derivative: bool = false
@export var show_integral: bool = false
@export var use_polar_coordinates: bool = false

@export_group("Performance")
@export var max_plot_points: int = 1000
@export var optimization_level: int = 0  # 0: none, 1: medium, 2: high

@export_group("Export")
@export var export_image_path: String = ""
@export var export_csv_path: String = ""

const FunctionParser = preload("res://addons/advanced_math_grapher/math/function_parser.gd")
const GraphPlotter = preload("res://addons/advanced_math_grapher/graph/graph_plotter.gd")

@export var debug_mode: bool = false : set = set_debug_mode

var logger = Logger.get_instance()

var parsed_expression: MathExpression
var plotter: GraphPlotter
var parser: FunctionParser

func _init():
	parser = FunctionParser.new()
	plotter = GraphPlotter.new()
	logger.info("AdvancedMathGrapher initialized in _init()")

func _ready():
	logger.set_log_level(Logger.LogLevel.INFO)
	logger.set_development_mode(OS.is_debug_build())
	logger.info("AdvancedMathGrapher initialized")
	if _expression_list.is_empty():
		_expression_list = [
			{
				"expression": "x",
				"type": "Function",
				"display_name": "Default Function",
				"line_color": Color.BLUE,
				"line_width": 2.0,
				"line_style": "Solid",
				"show_derivative": false,
				"show_integral": false,
				"visible": true
			}
		]
	notify_property_list_changed()
	update_expressions()

	if not parser:
		parser = FunctionParser.new()
	if not plotter:
		plotter = GraphPlotter.new()
	logger.info("Setting initial function in _ready")
	call_deferred("set_function", function)  # 遅延呼び出しを使用

func _enter_tree():
	logger.info("AdvancedMathGrapher entered tree")
	if not parser:
		logger.info("parser initialized in _enter_tree()")
		parser = FunctionParser.new()
	if not plotter:
		logger.info("plotter initialized in _enter_tree()")
		plotter = GraphPlotter.new()

func _process(_delta):
	if size != plotter.plot_size:
		plotter.update_plot_size(size)
		update_graph()

func _draw():
	logger.info("_draw called")  # デバッグ出力
	logger.info("Current function: ", function)  # デバッグ出力
	logger.info("Parsed expression: ", parsed_expression.to_function() if parsed_expression else "None")  # デバッグ出力
	logger.info("Plotter: ", plotter)  # デバッグ出力
	logger.info("X range: ", [x_min, " to ", x_max])  # デバッグ出力
	logger.info("Y range: ", [y_min, " to ", y_max])  # デバッグ出力

	# グラフの描画
	if parsed_expression and plotter:
		logger.info("Attempting to plot expression: ", parsed_expression.to_function())  # デバッグ出力
		plotter.plot(self)
	else:
		logger.info("No parsed expression to plot")  # デバッグ出力
	_draw_axes()
	_draw_ticks_and_labels()

func set_function(new_function: String):
	function = new_function
	logger.info("Setting function to: ", function)
	if parser:
		logger.info("Parser exists, parsing function")
		var result = parser.parse_function(function)
		logger.info("Parse result: ", result)
		print("in set_function result: ",result);
		if result.has("expression") and result.expression != null:
			parsed_expression = result.expression
			parsed_expression.set_comments(result.comments)
			logger.info("Parsed expression set: ", parsed_expression.to_function())
		else:
			logger.info("Failed to parse expression, parsed_expression is null")
			parsed_expression = null
	else:
		logger.info("Parser is not initialized")
	logger.info("Calling update_graph()")
	update_graph()

func set_x_min(value: float):
	x_min = value
	update_graph()

func set_x_max(value: float):
	x_max = value
	update_graph()

func set_y_min(value: float):
	y_min = value
	update_graph()

func set_y_max(value: float):
	y_max = value
	update_graph()

# セッター関数の追加
func set_line_color(value: Color):
	line_color = value
	update_graph()

func set_line_width(value: float):
	line_width = value
	update_graph()

func set_line_style(value: int):
	line_style = value
	update_graph()
	
func set_debug_mode(enabled: bool):
	debug_mode = enabled
	if parser:
		parser.set_debug_mode(enabled)
	if debug_mode:
		logger.info("Debug mode enabled")
	else:
		logger.info("Debug mode disabled")

func update_graph():
	logger.info("update_graph called")
	if parsed_expression:
		if not plotter:
			plotter = GraphPlotter.new()
		plotter.expression = parsed_expression
		plotter.x_range = Vector2(x_min, x_max)
		plotter.y_range = Vector2(y_min, y_max)
		plotter.plot_size = size
		plotter.line_color = line_color
		plotter.line_width = line_width
		plotter.line_style = line_style
		logger.info("Plotter updated with:")
		logger.info("  Expression: ", parsed_expression.to_function())
		logger.info("  X range: ", plotter.x_range)
		logger.info("  Y range: ", plotter.y_range)
		logger.info("  Plot size: ", plotter.plot_size)
		logger.info("  Line color: ", plotter.line_color)
		logger.info("  Line width: ", plotter.line_width)
		logger.info("  Line style: ", plotter.line_style)
	else:
		logger.info("No parsed expression to update plotter")
	queue_redraw()
	logger.info("Graph update queued")

func _draw_axes():
	# 座標軸の描画
	var origin = _world_to_graph(Vector2.ZERO)
	draw_line(Vector2(0, origin.y), Vector2(size.x, origin.y), Color.WHITE, 1)
	draw_line(Vector2(origin.x, 0), Vector2(origin.x, size.y), Color.WHITE, 1)

func _draw_ticks_and_labels():
	# 目盛りとラベルの描画
	var font = ThemeDB.fallback_font
	var font_size = ThemeDB.fallback_font_size
	
	for x in range(ceil(x_min), floor(x_max) + 1):
		var pos = _world_to_graph(Vector2(x, 0))
		draw_line(pos - Vector2(0, 5), pos + Vector2(0, 5), Color.WHITE, 1)
		draw_string(font, pos + Vector2(-10, 20), str(x), HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
	
	for y in range(ceil(y_min), floor(y_max) + 1):
		var pos = _world_to_graph(Vector2(0, y))
		draw_line(pos - Vector2(5, 0), pos + Vector2(5, 0), Color.WHITE, 1)
		draw_string(font, pos - Vector2(30, 0), str(y), HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, Color.WHITE)

func _world_to_graph(point: Vector2) -> Vector2:
	# 数学的座標をグラフ上の座標に変換
	var x = (point.x - x_min) / (x_max - x_min) * size.x
	var y = size.y - (point.y - y_min) / (y_max - y_min) * size.y
	return Vector2(x, y)

func update_expressions():
	# 既存の式をクリア
	if plotter:
		logger.error("Nonexistent function 'clear_expressions'")
		# plotter.clear_expressions()
	
	# 新しい式を追加
	for expr in _expression_list:
		logger.error("Nonexistent function 'add_expression'")
		#plotter.add_expression(expr)
	notify_property_list_changed()

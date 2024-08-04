@tool
extends Control

class_name AdvancedMathGrapher

@export_group("Function")
@export_multiline var formula: String = "x" : set = set_formula
## Enter a mathematical formula. Use 'x' as the variable.
## Supported functions: sin, cos, tan, exp, log, sqrt

@export var enable_multiple_functions: bool = false
@export var function_list: Array[String] = []

@export_group("Graph Range")
@export var x_min: float = -10.0 : set = set_x_min
@export var x_max: float = 10.0 : set = set_x_max
@export var y_min: float = -10.0 : set = set_y_min
@export var y_max: float = 10.0 : set = set_y_max
@export var auto_adjust_range: bool = false

@export_group("Graph Style")
@export var line_color: Color = Color.BLUE
@export var line_width: float = 2.0
@export var line_style: int = 0  # 0: solid, 1: dashed, 2: dotted
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

const FormulaParser = preload("res://addons/advanced_math_grapher/math/formula_parser.gd")
const GraphPlotter = preload("res://addons/advanced_math_grapher/graph/graph_plotter.gd")

@export var debug_mode: bool = false : set = set_debug_mode

var logger = Logger.get_instance()

var parsed_expression: MathExpression
var plotter: GraphPlotter
var parser: FormulaParser

func _init():
	parser = FormulaParser.new()
	plotter = GraphPlotter.new()
	logger.info("AdvancedMathGrapher initialized in _init()")

func _ready():
	logger.set_log_level(Logger.LogLevel.INFO)
	logger.set_development_mode(OS.is_debug_build())
	logger.info("AdvancedMathGrapher initialized")
	if not parser:
		parser = FormulaParser.new()
	if not plotter:
		plotter = GraphPlotter.new()
	logger.info("Setting initial formula in _ready")
	call_deferred("set_formula", formula)  # 遅延呼び出しを使用

func _enter_tree():
	logger.info("AdvancedMathGrapher entered tree")
	if not parser:
		logger.info("parser initialized in _enter_tree()")
		parser = FormulaParser.new()
	if not plotter:
		logger.info("plotter initialized in _enter_tree()")
		plotter = GraphPlotter.new()

func _process(_delta):
	if size != plotter.plot_size:
		plotter.update_plot_size(size)
		update_graph()

func _draw():
	logger.info("_draw called")  # デバッグ出力
	logger.info("Current formula: ", formula)  # デバッグ出力
	logger.info("Parsed expression: ", parsed_expression.to_formula() if parsed_expression else "None")  # デバッグ出力
	logger.info("Plotter: ", plotter)  # デバッグ出力
	logger.info("X range: ", [x_min, " to ", x_max])  # デバッグ出力
	logger.info("Y range: ", [y_min, " to ", y_max])  # デバッグ出力

	# グラフの描画
	if parsed_expression and plotter:
		logger.info("Attempting to plot expression: ", parsed_expression.to_formula())  # デバッグ出力
		plotter.plot(self)
	else:
		logger.info("No parsed expression to plot")  # デバッグ出力
	_draw_axes()
	_draw_ticks_and_labels()

func set_formula(new_formula: String):
	formula = new_formula
	logger.info("Setting formula to: ", formula)
	if parser:
		logger.info("Parser exists, parsing formula")
		var result = parser.parse_formula(formula)
		logger.info("Parse result: ", result)
		print("in set_formula result: ",result);
		if result.has("expression") and result.expression != null:
			parsed_expression = result.expression
			parsed_expression.set_comments(result.comments)
			logger.info("Parsed expression set: ", parsed_expression.to_formula())
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
		plotter.color = line_color  # 色を設定
		logger.info("Plotter updated with:")
		logger.info("  Expression: ", parsed_expression.to_formula())
		logger.info("  X range: ", plotter.x_range)
		logger.info("  Y range: ", plotter.y_range)
		logger.info("  Plot size: ", plotter.plot_size)
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

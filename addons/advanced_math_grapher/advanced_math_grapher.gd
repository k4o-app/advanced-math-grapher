@tool
extends Control

class_name AdvancedMathGrapher

const FormulaParser = preload("res://addons/advanced_math_grapher/math/formula_parser.gd")
const GraphPlotter = preload("res://addons/advanced_math_grapher/graph/graph_plotter.gd")

# プロパティの定義
@export var formula: String = "x" : set = set_formula
@export var x_min: float = -10.0 : set = set_x_min
@export var x_max: float = 10.0 : set = set_x_max
@export var y_min: float = -10.0 : set = set_y_min
@export var y_max: float = 10.0 : set = set_y_max

@export var debug_mode: bool = false : set = set_debug_mode

var parsed_expression: MathExpression
var plotter: GraphPlotter
var parser: FormulaParser

func _init():
	parser = FormulaParser.new()
	plotter = GraphPlotter.new()
	print("AdvancedMathGrapher initialized in _init()")

func _enter_tree():
	print("AdvancedMathGrapher entered tree")
	if not parser:
		print("parser initialized in _enter_tree()")
		parser = FormulaParser.new()
	if not plotter:
		print("plotter initialized in _enter_tree()")
		plotter = GraphPlotter.new()

func _process(_delta):
	if size != plotter.plot_size:
		plotter.update_plot_size(size)
		update_graph()

func _draw():
	# グラフの描画
	if parsed_expression:
		plotter.plot(self)
	_draw_axes()
	_draw_ticks_and_labels()

func _ready():
	print("AdvancedMathGrapher _ready() called")
	if not parser:
		parser = FormulaParser.new()
	if not plotter:
		plotter = GraphPlotter.new()
	update_graph()

func set_formula(new_formula: String):
	# 数式が変更されたときの処理
	formula = new_formula
	print("Setting formula to: ", formula)
	if parser:
		parsed_expression = parser.parse_formula(formula)
		print("Parsed expression: ", parsed_expression.to_formula() if parsed_expression else "None")
	else:
		print("Parser is not initialized")
	print("Formula set to: ", formula)
	print("Parsed expression: ", parsed_expression.to_formula() if parsed_expression else "None")
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
		print("Debug mode enabled")
	else:
		print("Debug mode disabled")

func update_graph():
	if parsed_expression:
		if not plotter:
			plotter = GraphPlotter.new()
		plotter.expression = parsed_expression
		plotter.x_range = Vector2(x_min, x_max)
		plotter.y_range = Vector2(y_min, y_max)
		plotter.plot_size = size
	queue_redraw()
	print("Graph updated")

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

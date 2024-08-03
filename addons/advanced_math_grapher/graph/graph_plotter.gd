class_name GraphPlotter
extends RefCounted

var expression: MathExpression
var x_range: Vector2
var y_range: Vector2
var plot_size: Vector2
var color: Color = Color.BLUE

func plot(canvas: CanvasItem):
	if not expression:
		return
	
	match expression.get_expression_type():
		"ParametricFunction":
			plot_parametric(canvas)
		"ImplicitFunction":
			plot_implicit(canvas)
		_:
			plot_function(canvas)

func plot_function(canvas: CanvasItem):
	var points = []
	var step = (x_range.y - x_range.x) / plot_size.x
	
	for i in range(plot_size.x):
		var x = x_range.x + i * step
		var y = expression.evaluate({"x": x})
		if y is float:
			points.append(world_to_screen(Vector2(x, y)))
	
	for i in range(1, points.size()):
		canvas.draw_line(points[i-1], points[i], color)

func plot_parametric(canvas: CanvasItem):
	var points = []
	var step = (x_range.y - x_range.x) / plot_size.x
	
	for i in range(plot_size.x):
		var t = x_range.x + i * step
		var point = expression.evaluate({"t": t})
		if point is Vector2:
			points.append(world_to_screen(point))
	
	for i in range(1, points.size()):
		canvas.draw_line(points[i-1], points[i], color)

func plot_implicit(canvas: CanvasItem):
	var step_x = (x_range.y - x_range.x) / plot_size.x
	var step_y = (y_range.y - y_range.x) / plot_size.y
	
	for i in range(plot_size.x):
		for j in range(plot_size.y):
			var x = x_range.x + i * step_x
			var y = y_range.x + j * step_y
			var value = expression.evaluate({"x": x, "y": y})
			if value is float and abs(value) < 0.1:  # 0に近い値を描画
				canvas.draw_circle(world_to_screen(Vector2(x, y)), 1, color)

func world_to_screen(point: Vector2) -> Vector2:
	var x = (point.x - x_range.x) / (x_range.y - x_range.x) * plot_size.x
	var y = plot_size.y - (point.y - y_range.x) / (y_range.y - y_range.x) * plot_size.y
	return Vector2(x, y)

func update_plot_size(new_size: Vector2):
	plot_size = new_size

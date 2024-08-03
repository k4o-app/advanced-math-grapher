@tool
extends SyntaxHighlighter

const MathExpression = preload("res://addons/advanced_math_grapher/math/math_expression.gd")
const FormulaParser = preload("res://addons/advanced_math_grapher/math/formula_parser.gd")

var number_color: Color = Color(0.63, 0.86, 0.95)  # 水色
var function_color: Color = Color(0.96, 0.76, 0.05)  # 黄色
var operator_color: Color = Color(0.86, 0.44, 0.84)  # 紫色
var variable_color: Color = Color(0.22, 0.71, 0.29)  # 緑色
var parenthesis_color: Color = Color(1.0, 1.0, 1.0)  # 白色
var comment_color: Color = Color(0.5, 0.5, 0.5)  # グレー

var text_edit: TextEdit
var parser: FormulaParser

func _init(text_edit: TextEdit):
	self.text_edit = text_edit
	self.parser = FormulaParser.new()

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var highlighting = {}
	var text = text_edit.text  # 全テキストを取得
	var result = parser.parse_formula(text)
	
	if result.expression:
		_highlight_expression(result.expression, highlighting, text, 0)
	
	# コメントのハイライト
	for comment in result.comments:
		_add_highlight(highlighting, comment.start, comment.end + 1, comment_color)
	
	# 行ごとのハイライトに変換
	var line_start = _get_line_start_index(line)
	var line_end = _get_line_end_index(line)
	var line_highlighting = {}
	for pos in highlighting:
		if line_start <= pos and pos < line_end:
			line_highlighting[pos - line_start] = highlighting[pos]
	
	return line_highlighting

func _highlight_expression(expression: MathExpression, highlighting: Dictionary, text: String, start: int) -> int:
	var expr_text = text.substr(start)
	var expr_length = 0
	
	match expression.get_expression_type():
		"Constant":
			var value_str = str(expression.value)
			var value_pos = expr_text.find(value_str)
			if value_pos != -1:
				_add_highlight(highlighting, start + value_pos, start + value_pos + len(value_str), number_color)
				expr_length = value_pos + len(value_str)
		"Variable":
			var var_pos = expr_text.find(expression.name)
			if var_pos != -1:
				_add_highlight(highlighting, start + var_pos, start + var_pos + len(expression.name), variable_color)
				expr_length = var_pos + len(expression.name)
		"BinaryOperation":
			expr_length += _highlight_expression(expression.get_left(), highlighting, text, start)
			var op_str = expression.get_operator()
			var op_pos = expr_text.find(op_str, expr_length)
			if op_pos != -1:
				_add_highlight(highlighting, start + op_pos, start + op_pos + len(op_str), operator_color)
				expr_length = op_pos + len(op_str)
			expr_length += _highlight_expression(expression.get_right(), highlighting, text, start + expr_length)
		"Function":
			var func_pos = expr_text.find(expression.name)
			if func_pos != -1:
				_add_highlight(highlighting, start + func_pos, start + func_pos + len(expression.name), function_color)
				expr_length = func_pos + len(expression.name)
				var paren_pos = expr_text.find("(", expr_length)
				if paren_pos != -1:
					_add_highlight(highlighting, start + paren_pos, start + paren_pos + 1, parenthesis_color)
					expr_length = paren_pos + 1
					for arg in expression.get_children():
						expr_length += _highlight_expression(arg, highlighting, text, start + expr_length)
						var comma_pos = expr_text.find(",", expr_length)
						if comma_pos != -1 and arg != expression.get_children()[-1]:
							expr_length = comma_pos + 1
					var close_paren_pos = expr_text.find(")", expr_length)
					if close_paren_pos != -1:
						_add_highlight(highlighting, start + close_paren_pos, start + close_paren_pos + 1, parenthesis_color)
						expr_length = close_paren_pos + 1
	
	return expr_length

func _add_highlight(highlighting: Dictionary, start: int, end: int, color: Color):
	highlighting[start] = {"color": color}
	highlighting[end] = {"color": Color.WHITE}

func _get_line_start_index(line: int) -> int:
	var total_length = 0
	for i in range(line):
		total_length += text_edit.get_line(i).length() + 1  # +1 for the newline character
	return total_length

func _get_line_end_index(line: int) -> int:
	return _get_line_start_index(line) + text_edit.get_line(line).length()

class_name FormulaParser
extends RefCounted

const MathExpression = preload("res://addons/advanced_math_grapher/math/math_expression.gd")
const Constant = preload("res://addons/advanced_math_grapher/math/constant.gd")
const Variable = preload("res://addons/advanced_math_grapher/math/variable.gd")
const BinaryOperation = preload("res://addons/advanced_math_grapher/math/binary_operation.gd")
const Function = preload("res://addons/advanced_math_grapher/math/function.gd")

var debug_mode: bool = false

func parse_formula(formula_str: String) -> MathExpression:
	var tokens = tokenize(formula_str)
	var result = parse_expression(tokens)
	if result:
		print("Parsed formula: ", formula_str, " to expression: ", result.to_formula())
	else:
		print("Failed to parse formula: ", formula_str)
	return result

func tokenize(formula: String) -> Array:
	var tokens = []
	var current_token = ""
	var i = 0
	while i < formula.length():
		var char = formula[i]
		if char in "+-*/^()":
			if current_token:
				tokens.append(current_token)
				current_token = ""
			tokens.append(char)
		elif char.is_valid_float() or char == ".":
			current_token += char
		elif char.is_valid_identifier():
			if current_token and current_token.is_valid_float():
				tokens.append(current_token)
				current_token = ""
			current_token += char
		elif char == " ":
			if current_token:
				tokens.append(current_token)
				current_token = ""
		i += 1
	if current_token:
		tokens.append(current_token)
	return tokens

func parse_expression(tokens: Array) -> MathExpression:
	var expr = parse_term(tokens)
	while tokens and tokens[0] in "+-":
		var op = tokens.pop_front()
		var right = parse_term(tokens)
		expr = BinaryOperation.new(expr, right, op)
	return expr

func parse_term(tokens: Array) -> MathExpression:
	var expr = parse_factor(tokens)
	while tokens and tokens[0] in "*/":
		var op = tokens.pop_front()
		var right = parse_factor(tokens)
		expr = BinaryOperation.new(expr, right, op)
	return expr

func parse_factor(tokens: Array) -> MathExpression:
	if not tokens:
		return null
	var token = tokens.pop_front()
	if debug_mode:
		print("parse_factor: Processing token: ", token)

	if token == "(":
		var expr = parse_expression(tokens)
		if tokens and tokens[0] == ")":
			tokens.pop_front()
		return expr
	elif token in ["sin", "cos", "tan", "exp", "log", "sqrt", "sinh", "cosh", "tanh"]:
		if tokens and tokens[0] == "(":
			tokens.pop_front()
			var arg = parse_expression(tokens)
			if tokens and tokens[0] == ")":
				tokens.pop_front()
			return create_function(token, [arg])
	elif is_valid_float(token):
		return Constant.new(float(token))
	else:
		return Variable.new(token)

	push_error("Unexpected token: " + token)
	return null

func is_valid_float(s: String) -> bool:
	# 整数、小数、および指数表記をサポート
	var regex = RegEx.new()
	regex.compile("^-?\\d*\\.?\\d+([eE][-+]?\\d+)?$")
	return regex.search(s) != null

func create_function(name: String, args: Array[MathExpression]) -> Function:
	return Function.new(name, args)

func set_debug_mode(enabled: bool):
	debug_mode = enabled
	if debug_mode:
		print("Debug mode enabled in FormulaParser")
	else:
		print("Debug mode disabled in FormulaParser")



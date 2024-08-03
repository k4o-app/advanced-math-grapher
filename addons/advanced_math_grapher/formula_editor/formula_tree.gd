@tool
extends Tree

var root: TreeItem

const MathExpression = preload("res://addons/advanced_math_grapher/math/math_expression.gd")

func _ready():
	set_column_titles_visible(true)
	set_column_title(0, "Expression")
	set_columns(1)

	# アンカーを設定
	anchor_right = 1
	anchor_bottom = 1
	
	# サイズフラグを設定
	size_flags_vertical = SIZE_EXPAND_FILL
	size_flags_horizontal = SIZE_EXPAND_FILL
	
	# サイズの遅延設定
	call_deferred("set_custom_minimum_size", Vector2(0, 200))
	
	print("FormulaTree initialized")

func build_tree(expression: MathExpression):
	clear()
	root = create_item()
	root.set_text(0, "Expression")
	if expression:
		_add_expression_to_tree(root, expression)
		print("Tree built with expression: ", expression.to_formula())
	else:
		print("Failed to build tree: expression is null")

func _add_expression_to_tree(parent: TreeItem, expression: MathExpression):
	if not expression:
		print("Attempted to add null expression to tree")
		return

	var item = create_item(parent)

	match expression.get_expression_type():
		"Constant":
			item.set_text(0, str(expression.value))
		"Variable":
			item.set_text(0, expression.name)
		"BinaryOperation":
			item.set_text(0, expression.get_operator())
			_add_expression_to_tree(item, expression.get_left())
			_add_expression_to_tree(item, expression.get_right())
		"Function":
			item.set_text(0, expression.name)
			for arg in expression.arguments:
				_add_expression_to_tree(item, arg)
		_:
			item.set_text(0, "Unknown")
	
	print("Added item: ", item.get_text(0))  # デバッグ出力

func get_expression() -> MathExpression:
	return _build_expression_from_item(root.get_first_child())

func _build_expression_from_item(item: TreeItem) -> MathExpression:
	if not item:
		print("No item found")  # デバッグ出力
		return null

	var text = item.get_text(0)
	print("Building expression from item: ", text)  # デバッグ出力
	
	if item.get_child_count() == 0:
		if text.is_valid_float():
			return MathExpression.new().Constant.new(float(text))
		else:
			return MathExpression.new().Variable.new(text)
	
	if item.get_child_count() == 1:
		return MathExpression.new().Function.new(text, _build_expression_from_item(item.get_first_child()))
	
	if item.get_child_count() == 2:
		return BinaryOperation.new(
			_build_expression_from_item(item.get_first_child()),
			_build_expression_from_item(item.get_first_child().get_next()),
			text
		)
	
	print("Unknown expression type")  # デバッグ出力
	return null

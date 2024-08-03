@tool
extends EditorPlugin

var formula_editor
var logger

func _enter_tree():
	# Loggerの初期化と設定
	logger = Logger.get_instance()
	logger.set_log_level(Logger.LogLevel.DEBUG)  # 開発中はDEBUGレベルに設定
	logger.info("Advanced Math Grapher plugin initialized")

	# プラグインがエディタに読み込まれたときの処理
	formula_editor = preload("res://addons/advanced_math_grapher/formula_editor/formula_editor.gd").new()
	add_custom_type("AdvancedMathGrapher", "Control", preload("res://addons/advanced_math_grapher/core/advanced_math_grapher.gd"), preload("res://addons/advanced_math_grapher/icon.png"))
	add_inspector_plugin(formula_editor)

func _exit_tree():
	# プラグインがエディタから削除されたときの処理
	remove_custom_type("AdvancedMathGrapher")
	remove_inspector_plugin(formula_editor)
	formula_editor.free()

func _has_main_screen():
	return false

func _make_visible(visible):
	pass

func _get_plugin_name():
	return "Advanced Math Grapher"

func _get_plugin_icon():
	return preload("res://addons/advanced_math_grapher/icon.png")

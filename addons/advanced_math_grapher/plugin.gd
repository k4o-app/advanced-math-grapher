@tool
extends EditorPlugin

const Logger = preload("res://addons/advanced_math_grapher/utils/logger.gd")
var inspector_plugin

var logger

func _enter_tree():
	# Loggerの初期化と設定
	logger = Logger.get_instance()
	logger.set_log_level(Logger.LogLevel.DEBUG)  # 開発中はDEBUGレベルに設定
	logger.info("Advanced Math Grapher plugin initialized")

	inspector_plugin = preload("res://addons/advanced_math_grapher/advanced_math_grapher_inspector_plugin.gd").new()

	add_custom_type("AdvancedMathGrapher", "Control", preload("res://addons/advanced_math_grapher/core/advanced_math_grapher.gd"), preload("res://addons/advanced_math_grapher/icon.png"))
	add_inspector_plugin(inspector_plugin)

func _exit_tree():
	remove_custom_type("AdvancedMathGrapher")
	remove_inspector_plugin(inspector_plugin)
	inspector_plugin.free()

func _has_main_screen():
	return false

func _make_visible(visible):
	pass

func _get_plugin_name():
	return "Advanced Math Grapher"

func _get_plugin_icon():
	return preload("res://addons/advanced_math_grapher/icon.png")

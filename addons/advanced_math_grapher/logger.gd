class_name Logger
extends RefCounted

enum LogLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR
}

var current_level = LogLevel.INFO
var is_development_mode = true

const ANSI_COLORS = {
	"reset": "\u001b[0m",
	"bold": "\u001b[1m",
	"debug": "\u001b[36m",  # シアン
	"info": "\u001b[32m",   # 緑
	"warning": "\u001b[33m", # 黄
	"error": "\u001b[31m",  # 赤
}

static var _instance: Logger = null

static func get_instance() -> Logger:
	if _instance == null:
		_instance = Logger.new()
	return _instance

func _init():
	if _instance != null:
		push_error("Logger is a singleton and should not be instantiated directly. Use Logger.get_instance() instead.")
	else:
		_instance = self
		set_development_mode(OS.is_debug_build())

func set_log_level(level: LogLevel):
	current_level = level

func set_development_mode(is_dev: bool):
	is_development_mode = is_dev

func debug(message: String, args = null) -> void:
	if current_level <= LogLevel.DEBUG and is_development_mode:
		_log("[DEBUG]", message, args, "debug")

func info(message: String, args = null) -> void:
	if current_level <= LogLevel.INFO:
		_log("[INFO]", message, args, "info")

func warning(message: String, args = null) -> void:
	if current_level <= LogLevel.WARNING:
		_log("[WARNING]", message, args, "warning")

func error(message: String, args = null) -> void:
	if current_level <= LogLevel.ERROR:
		_log("[ERROR]", message, args, "error")

func _log(level: String, message: String, args, color: String) -> void:
	var final_message = ANSI_COLORS[color] + ANSI_COLORS["bold"] + level + ANSI_COLORS["reset"] + " " + message
	if args != null:
		final_message += " " + _format_value(args)
	print(final_message)

func _format_value(value) -> String:
	if value is Array:
		return "[" + ", ".join(value.map(func(v): return _format_value(v))) + "]"
	elif value is Dictionary:
		var items = []
		for k in value:
			items.append(str(k) + ": " + _format_value(value[k]))
		return "{" + ", ".join(items) + "}"
	elif value is String:
		return "\"" + value + "\""
	else:
		return str(value)

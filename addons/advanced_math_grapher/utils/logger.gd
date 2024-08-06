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

const BB_CODES = {
	"bold": "[b]",
	"end_bold": "[/b]",
	"debug": "[color=cyan]",  # シアン
	"info": "[color=green]",   # 緑
	"warning": "[color=yellow]", # 黄
	"error": "[color=red]",  # 赤
	"end_color": "[/color]",
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
	var stack_info = _get_stack_info()
	message = message.replace("\n", "\\n")  # 改行を \n に置換

	var final_message = BB_CODES[color] + BB_CODES["bold"] + level + BB_CODES["end_bold"]
	final_message += " " + stack_info
	final_message += " " + message
	
	if args != null:
		final_message += " " + _format_value(args)
	
	final_message += BB_CODES["end_color"]
	print_rich(final_message)

func _get_stack_info() -> String:
	var stack = get_stack()
	if stack.size() <= 3:
		return "[Unknown]"
	
	var frame = stack[3]  # インデックス3がログを呼び出した関数のフレームになるはず
	if frame.has("function") and frame.has("source") and frame.has("line"):
		var function_name = frame["function"]
		var file_name = frame["source"].get_file()
		var line_number = frame["line"]
		return "[%s (%s:%s)]" % [function_name, file_name, line_number]
	else:
		return "[Unknown]"


func _format_value(value) -> String:
	if value is Array:
		return "[" + ", ".join(value.map(func(v): return _format_value(v))) + "]"
	elif value is Dictionary:
		var items = []
		for k in value:
			items.append(str(k) + ": " + _format_value(value[k]))
		return "{" + ", ".join(items) + "}"
	elif value is String:
		return "\"" + value.replace("\n", "\\n") + "\""  # 文字列内の改行も \n に置換
	else:
		return str(value)

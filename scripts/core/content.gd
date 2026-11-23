extends RefCounted

class Definition extends Resource:
	var id: String
	var data: Dictionary

	func _init(key := "", fields := {}) -> void:
		id = key
		data = fields.duplicate(true)

static var books: Dictionary

static func read(path: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	return parser.data if parser.data is Dictionary else {}

static func _book(book: String) -> Dictionary:
	if not books.has(book):
		var entries := {}
		var source := read("res://data/" + book + ".json")
		for id in source:
			entries[id] = Definition.new(id, source[id])
		books[book] = entries
	return books[book]

static func definition(book: String, key: String) -> Dictionary:
	var record: Definition = _book(book).get(key)
	return record.data.duplicate(true) if record else {}

static func keys(book: String) -> Array:
	return _book(book).keys()


extends Node

const SAVE_PATH = "user://savegame.json"

var data = {
	"has_save": false,
	"checkpoint": Vector2(-200, 90),
	"coins": 0,
	"abilities": {
		"double_jump": false,
		"wall_jump": false,
		"infinite_jump": false
	}
}


func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	data["has_save"] = true
	var json_data = data.duplicate(true)

	# Vector2 needs conversion
	json_data["checkpoint"] = {
		"x": data["checkpoint"].x,
		"y": data["checkpoint"].y
	}

	file.store_string(JSON.stringify(json_data))
	file.close()


func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json = JSON.parse_string(file.get_as_text())

	if json:
		data = json

		data["checkpoint"] = Vector2(
			data["checkpoint"]["x"],
			data["checkpoint"]["y"]
		)


func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

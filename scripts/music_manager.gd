extends AudioStreamPlayer

var tracks = {
	"exploration": preload("uid://dhmfh8pm4j7ci"),
	"exploration_2": preload("uid://ylskbgpu3orj"),
	"flashback": preload("uid://bpby6x1fuinje"),
}

func play_music(track_name: String) -> void:
	if not tracks.has(track_name):
		return

	if stream == tracks[track_name] and playing:
		return

	# No music currently playing → start directly and fade in
	if not playing:
		stream = tracks[track_name]
		play()
		return

	# Music is already playing → fade out, switch, fade in
	var fade_out = create_tween()
	fade_out.tween_property(self, "volume_db", -80.0, 0.5)

	fade_out.finished.connect(func():
		stream = tracks[track_name]
		play()

		var fade_in = create_tween()
		fade_in.tween_property(self, "volume_db", 0.0, 0.5)
	)

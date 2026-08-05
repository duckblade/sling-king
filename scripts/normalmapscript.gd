@tool
extends Node

@export var sprite_frames: SpriteFrames
@export var diffuse_anim: String = "idle"
@export var normal_anim: String = "idle_normal"
@export var run_it: bool = false:
	set(value):
		if value:
			merge()

func _bake_frame(tex: Texture2D) -> Texture2D:
	if tex is AtlasTexture:
		var atlas := tex as AtlasTexture
		var region := atlas.region
		var src_img := atlas.atlas.get_image()
		var cropped := Image.create(int(region.size.x), int(region.size.y), false, src_img.get_format())
		cropped.blit_rect(src_img, region, Vector2i.ZERO)
		return ImageTexture.create_from_image(cropped)
	return tex # already a plain texture, use as-is

func merge():
	if not sprite_frames:
		push_error("Assign a SpriteFrames resource first")
		return
	if not sprite_frames.has_animation(diffuse_anim) or not sprite_frames.has_animation(normal_anim):
		push_error("Both animations must exist")
		return

	var count = sprite_frames.get_frame_count(diffuse_anim)
	if count != sprite_frames.get_frame_count(normal_anim):
		push_error("Frame counts don't match between %s and %s" % [diffuse_anim, normal_anim])
		return

	for i in count:
		var diffuse_tex = _bake_frame(sprite_frames.get_frame_texture(diffuse_anim, i))
		var normal_tex = _bake_frame(sprite_frames.get_frame_texture(normal_anim, i))
		var duration = sprite_frames.get_frame_duration(diffuse_anim, i)

		var canvas_tex = CanvasTexture.new()
		canvas_tex.diffuse_texture = diffuse_tex
		canvas_tex.normal_texture = normal_tex

		sprite_frames.set_frame(diffuse_anim, i, canvas_tex, duration)

	print("Merged %d frames into '%s' with normal maps attached" % [count, diffuse_anim])

extends RefCounted
class_name TextureAtlas

static func create_atlas() -> ImageTexture:
	const TILE := 16
	const GRID := 4
	var image := Image.create(TILE * GRID, TILE * GRID, false, Image.FORMAT_RGBA8)
	var colors := [
		[Color("#70b943"), Color("#559c32"), Color("#6b4b2e")],
		[Color("#8b603a")], [Color("#777b80")], [Color("#b8b07b")],
		[Color("#6d5032")], [Color("#a57a49")], [Color("#3f7c37")],
		[Color("#777777")], [Color("#8b8f92")], [Color("#bd9b68")],
		[Color("#b9e6e9", 0.62)], [Color("#45464b")], [Color("#428ed0", 0.78)],
		[Color("#34383c")], [Color("#b1a29a")], [Color("#edf3f4")]
	]
	for tile in range(16):
		var base: Color = colors[tile][0]
		var ox := (tile % GRID) * TILE
		var oy := (tile / GRID) * TILE
		for y in range(TILE):
			for x in range(TILE):
				var noise := ((x * 13 + y * 7 + tile * 11) % 17) / 170.0
				var c := base
				if tile == 0:
					c = Color("#70b943") if (x + y * 3) % 7 != 0 else Color("#4f9232")
				elif tile == 1:
					c = Color("#6b4b2e") if y > 4 else Color("#559c32")
				elif tile == 5:
					c = Color("#9b7042") if x % 5 < 3 else Color("#72502f")
				elif tile == 6:
					c = Color("#a57a49") if (x + y) % 5 else Color("#72502f")
				elif tile == 7:
					c = Color("#3f7c37") if (x * 3 + y * 5) % 6 else Color("#2f642e")
				elif tile == 10:
					c = Color("#b9e6e9", 0.62) if x in [0, 15] or y in [0, 15] else Color("#b9e6e9", 0.16)
				elif tile == 12:
					c = Color("#428ed0", 0.78) if (x + y) % 4 else Color("#367bb8", 0.78)
				elif tile == 13:
					c = Color("#777b80") if (x * 5 + y * 3) % 11 > 2 else Color("#34383c")
				elif tile == 14:
					c = Color("#777b80") if (x * 5 + y * 3) % 9 > 2 else Color("#b1a29a")
				elif tile == 15:
					c = Color("#edf3f4") if (x + y) % 7 else Color("#d8e4e7")
				elif tile not in [0, 1, 5, 6, 7, 10, 12, 13, 14, 15]:
					c = base.lightened(noise)
				image.set_pixel(ox + x, oy + y, c)
	return ImageTexture.create_from_image(image)

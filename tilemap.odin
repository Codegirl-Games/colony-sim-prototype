package main

import rl "vendor:raylib"

Tilemap :: struct {
	width:  int,
	height: int,
	tiles:  []u8,
}

tilemap_init :: proc() -> Tilemap {
	return Tilemap {
		width = MAP_WIDTH,
		height = MAP_HEIGHT,
		tiles = make([]u8, MAP_WIDTH * MAP_HEIGHT),
	}
}

tilemap_destroy :: proc(tilemap: ^Tilemap) {
	delete(tilemap.tiles)
}

tile_in_bounds :: proc(tilemap: ^Tilemap, x: int, y: int) -> bool {
	// learning from another game, this will become handy
	return x >= 0 && x < tilemap.width && y >= 0 && y < tilemap.height
}

tile_index :: proc(tilemap: ^Tilemap, x, y: int) -> int {
	return y * tilemap.width + x
}

tile_color :: proc(type_id: u8) -> rl.Color {
	// going to make this a table at some point but for now, we do this
	switch type_id {
	case 0:
		return {72, 112, 68, 255}
	case:
		return rl.MAGENTA
	}
}

tilemap_draw :: proc(tilemap: ^Tilemap) {
	for y in 0 ..< tilemap.height {
		for x in 0 ..< tilemap.width {
			index := tile_index(tilemap, x, y)
			type_id := tilemap.tiles[index]
			color := tile_color(type_id)

			px := i32(x * TILE_SIZE)
			py := i32(y * TILE_SIZE)

			rl.DrawRectangle(px, py, TILE_SIZE, TILE_SIZE, color)
			rl.DrawRectangleLines(px, py, TILE_SIZE, TILE_SIZE, {40, 50, 38, 255})
		}
	}
}


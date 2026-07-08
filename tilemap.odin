package main

import rl "vendor:raylib"

Tile_Def :: struct {
	name:      cstring,
	color:     rl.Color,
	walkable:  bool,
	move_cost: int,
}

Tilemap :: struct {
	width:  int,
	height: int,
	tiles:  []u8,
}

TILE_DEFS: [TILE_COUNT]Tile_Def = {
	0 = {name = "grass", color = {72, 112, 68, 255}, walkable = true, move_cost = 10},
	1 = {name = "wall", color = {90, 90, 95, 255}, walkable = false, move_cost = 0},
	2 = {name = "road", color = {120, 100, 70, 255}, walkable = true, move_cost = 1},
	3 = {name = "mud", color = {60, 55, 40, 255}, walkable = true, move_cost = 20},
	4 = {name = "water", color = {50, 90, 140, 255}, walkable = false, move_cost = 0},
}

tile_def :: proc(type_id: u8) -> ^Tile_Def {
	if int(type_id) >= TILE_COUNT {
		return &TILE_DEFS[TILE_GRASS]
	}
	return &TILE_DEFS[type_id]
}

tilemap_init :: proc() -> Tilemap {
	tm := Tilemap {
		width  = MAP_WIDTH,
		height = MAP_HEIGHT,
		tiles  = make([]u8, MAP_WIDTH * MAP_HEIGHT),
	}
	// test wall
	// Horizontal mud strip (expensive, cost 20 per step)
	for y in 8 ..< 18 {
		tm.tiles[tile_index(&tm, 5, y)] = 3 // mud
	}
	// Road detour (cheap, cost 1 per step) — goes right, down, left
	for x in 5 ..< 12 {
		tm.tiles[tile_index(&tm, x, 8)] = 2 // road top
		tm.tiles[tile_index(&tm, x, 18)] = 2 // road bottom
	}
	for y in 8 ..< 19 {
		tm.tiles[tile_index(&tm, 11, y)] = 2 // road right side
	}
	return tm
}

tilemap_destroy :: proc(tilemap: ^Tilemap) {
	delete(tilemap.tiles)
}

tilemap_get :: proc(tilemap: ^Tilemap, x, y: int) -> u8 {
	if !tile_in_bounds(tilemap, x, y) {
		return TILE_WALL
	}

	return tilemap.tiles[tile_index(tilemap, x, y)]
}

tilemap_set :: proc(tilemap: ^Tilemap, x, y: int, type_id: u8) {
	if !tile_in_bounds(tilemap, x, y) {
		return
	}
	tilemap.tiles[tile_index(tilemap, x, y)] = type_id
}

tile_in_bounds :: proc(tilemap: ^Tilemap, x: int, y: int) -> bool {
	// learning from another game, this will become handy
	return x >= 0 && x < tilemap.width && y >= 0 && y < tilemap.height
}

tile_index :: proc(tilemap: ^Tilemap, x, y: int) -> int {
	return y * tilemap.width + x
}

tilemap_draw_selection :: proc(tilemap: ^Tilemap, cam: ^Camera2D, selection: ^Selection) {
	if !selection.active {
		return
	}

	wx := f32(selection.tile.x * TILE_SIZE)
	wy := f32(selection.tile.y * TILE_SIZE)
	sx, sy := world_to_screen(cam, wx, wy)
	tile_px := f32(TILE_SIZE) * cam.zoom

	highlight := rl.Color{255, 220, 80, 120}
	rl.DrawRectangle(i32(sx), i32(sy), i32(tile_px), i32(tile_px), highlight)
	rl.DrawRectangleLines(i32(sx), i32(sy), i32(tile_px), i32(tile_px), rl.GOLD)
}
tilemap_draw :: proc(tilemap: ^Tilemap, camera: ^Camera2D) {
	tile_px := f32(TILE_SIZE) * camera.zoom

	for y in 0 ..< tilemap.height {
		for x in 0 ..< tilemap.width {
			wx := f32(x * TILE_SIZE)
			wy := f32(y * TILE_SIZE)
			sx, sy := world_to_screen(camera, wx, wy)

			if sx + tile_px < 0 || sy + tile_px < 0 {continue}
			if sx > f32(WINDOW_WIDTH) || sy > f32(WINDOW_HEIGHT) {continue}

			index := tile_index(tilemap, x, y)
			color := tile_color(tilemap.tiles[index])

			rl.DrawRectangle(i32(sx), i32(sy), i32(tile_px), i32(tile_px), color)
			rl.DrawRectangleLines(i32(sx), i32(sy), i32(tile_px), i32(tile_px), {40, 50, 38, 255})
		}
	}
}


tile_walkable :: proc(tilemap: ^Tilemap, x, y: int) -> bool {
	if !tile_in_bounds(tilemap, x, y) {return false}
	def := tile_def(tilemap_get(tilemap, x, y))

	return def.walkable
}

tile_cost :: proc(tm: ^Tilemap, x, y: int) -> int {
	if !tile_in_bounds(tm, x, y) {
		return max_path_int
	}
	def := tile_def(tilemap_get(tm, x, y))
	if !def.walkable {
		return max_path_int
	}
	return def.move_cost
}

tile_color :: proc(type_id: u8) -> rl.Color {
	return tile_def(type_id).color
}


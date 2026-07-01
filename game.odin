package main

import rl "vendor:raylib"

Game :: struct {
	running: bool,
	time:    f32, // total time elapsed
	tilemap: Tilemap,
}

game_init :: proc() -> Game {
	g := Game {
		running = true,
		time    = 0,
	}
	g.tilemap = tilemap_init()
	return g
}

game_update :: proc(g: ^Game, dt: f32) {
	g.time += dt

	if rl.IsKeyPressed(.ESCAPE) {
		g.running = false
	}
}

game_draw :: proc(g: ^Game) {
	tilemap_draw(&g.tilemap)
	fps := rl.GetFPS()
	rl.DrawText(rl.TextFormat("FPS: %i", fps), 10, 36, 20, rl.GREEN)
	rl.DrawText(rl.TextFormat("Time: %.1fs", g.time), 10, 62, 20, rl.GRAY)
}

game_shutdown :: proc(g: ^Game) {
	tilemap_destroy(&g.tilemap)
}


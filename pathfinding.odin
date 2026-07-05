package main

Path :: struct {
	tiles: []Tile_Coord,
	count: int,
}

path_clear :: proc(path: ^Path) {
	delete(path.tiles)
	path.tiles = nil
	path.count = 0
}

pathfind_bfs :: proc(tilemap: ^Tilemap, start, goal: Tile_Coord, path: ^Path) -> bool {
	path_clear(path)

	if start == goal {
		path.tiles[0] = start
		path.count = 1
		return true
	}

	w, h := tilemap.width, tilemap.height

	parents: [MAP_HEIGHT][MAP_WIDTH]Tile_Coord
	visited: [MAP_HEIGHT][MAP_WIDTH]bool

	found := false

	for y in 0 ..< h {
		for x in 0 ..< w {
			parents[y][x] = {-1, -1}
		}
	}

	queue: [MAP_WIDTH * MAP_HEIGHT]Tile_Coord
	head, tail: int = 0, 0

	queue[tail] = start; tail += 1
	visited[start.y][start.x] = true
	parents[start.y][start.x] = start

	for head < tail {
		current := queue[head]; head += 1

		if current == goal {
			found = true
			break
		}

		for offset in NEIGHBOR_OFFSET {
			nx := current.x + offset.x
			ny := current.y + offset.y
			if !tile_in_bounds(tilemap, nx, ny) ||
			   visited[ny][nx] ||
			   !tile_walkable(tilemap, nx, ny) {
				continue
			}

			visited[ny][nx] = true
			parents[ny][nx] = current
			queue[tail] = {nx, ny}
			tail += 1
		}
	}

	if !found {
		return false
	}

	rev: [MAX_PATH]Tile_Coord
	rev_count := 0
	cur := goal
	for {
		rev[rev_count] = cur
		rev_count += 1
		if cur == start {
			break
		}
		cur = parents[cur.y][cur.x]
		if rev_count >= MAX_PATH {
			return false
		}
	}

	path.tiles = make([]Tile_Coord, rev_count)
	path.count = rev_count
	for i in 0 ..< rev_count {
		path.tiles[i] = rev[rev_count - 1 - i]
	}
	return true
}


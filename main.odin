package main
import c "core:c"
import fmt "core:fmt"
import math "core:math"
import os "core:os"
import rl "vendor:raylib"

HERO_DEFAULT_WIDTH :: 100.0
imode :: enum {
	debug,
}
HERO_DEFAULT_HEIGHT :: 100.0
COLOR_RED :: rl.Color{255, 0, 0, 255}
HERO_MOVESPEED_MAX :: 500
WINDOW_HEIGHT :: 720
WINDOW_WIDTH :: 1280
mode := imode.debug

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.SetTargetFPS(144)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "D2RENA")

	hero := new_hero(
		width = 100.0,
		height = 100.0,
		pos_x = 0,
		pos_y = 360,
		movespeed = 300,
		move_velocity = 0,
		move_acceleration = .2,
		move_direction = nil,
		weight = 2,
	)

	for !rl.WindowShouldClose() {
		//------------------------LOGIC------------------------------------
		hero_moved_last_frame := hero.moved_this_frame
		hero.moved_this_frame = false
		//defer hero.moved_this_frame = false
		x := hero.pos_x
		y := hero.pos_y

		if rl.IsKeyDown(.LEFT) {
			direction := direction.left
			new_hero_velocity := calc_hero_velocity(hero, direction)
			move_entity(&hero, direction, new_hero_velocity)
			hero.moved_this_frame = true
		}
		if rl.IsKeyDown(.RIGHT) {
			direction := direction.right
			new_hero_velocity := calc_hero_velocity(hero, direction)
			move_entity(&hero, direction, new_hero_velocity)
			hero.moved_this_frame = true
		}
		if rl.IsKeyDown(.DOWN) {
			direction := direction.down
			new_hero_velocity := calc_hero_velocity(hero, direction)
			move_entity(&hero, direction, new_hero_velocity)
			hero.moved_this_frame = true
		}
		if rl.IsKeyDown(.UP) {
			direction := direction.up
			new_hero_velocity := calc_hero_velocity(hero, direction)
			move_entity(&hero, direction, new_hero_velocity)
			hero.moved_this_frame = true
		}
		rect := rl.Rectangle{hero.pos_x, hero.pos_y, hero.width, hero.height}
		if hero_moved_last_frame && !hero.moved_this_frame {
			move_entity(&hero, hero.move_direction, f32(hero.weight))
		}

		//-----------------------RENDERING-----------------------------------
		rl.BeginDrawing()
		rl.DrawFPS(5, 5)
		rl.ClearBackground({150, 190, 220, 255})

		//draw_terminal(0, f32(top_y) - 300)


		//tmpBuf :[]byte
		//debug_text := strings.concatenate({"X: ", strconv.write_int(tmpBuf[:], i64(x), 10), "Y: ", strconv.write_int(tmpBuf[:], i64(y), 10)})
		//debug_info_on_screen(0, 360, strings.clone_to_cstring(debug_text))


		//camera := rl.Camera2D{}
		draw_entity(&hero, rect)
		//rl.BeginMode2D(camera)
		//rl.EndMode2D()
		if hero_moved_last_frame && !hero.moved_this_frame {
			move_entity(&hero, hero.move_direction, f32(hero.weight) * 10)
		}

		rl.EndDrawing()
	}

	rl.CloseWindow()
}


/// ------------------------------------------ HERO -------------------------
Hero :: struct {
	width:             f32,
	height:            f32,
	pos_x:             f32,
	pos_y:             f32,
	movespeed:         f32,
	move_velocity:     f32,
	look_direction:    rl.Vector2,
	move_direction:    direction,
	move_acceleration: f32,
	weight:            int,
	last_frame_moved:  bool,
	moved_this_frame:  bool,
}



new_hero :: proc(
	width: f32,
	height: f32,
	pos_x: f32,
	pos_y: f32,
	movespeed: f32 = 10,
	move_velocity: f32 = 10,
	look_direction: rl.Vector2 = {0.0, -1.0},
	move_direction: direction = direction.None,
	move_acceleration: f32 = .2,
	weight: int,
) -> Hero {

	if movespeed > HERO_MOVESPEED_MAX {
		fmt.println("Error: hero speed cant be more than max speed")
		os.exit(1)
	}

	look_end_x := f32(rl.GetScreenWidth()) / 2.0
	look_end_y := f32(rl.GetScreenHeight()) / 2.0

	return Hero {
		width = width,
		height = height,
		pos_x = pos_x,
		pos_y = pos_y,
		movespeed = movespeed,
		move_velocity = move_velocity,
		look_direction = {look_end_x, look_end_y},
		move_direction = move_direction,
		move_acceleration = move_acceleration,
		weight = weight,
		last_frame_moved = false,
		moved_this_frame = false,
	}
}

direction :: enum {
	up,
	down,
	left,
	right,
	None,
}

Enemy :: struct {
    pos: rl.Vector2,
    movespeed: f16,
    velocity: f16,
    acceleration: f16,
    health: int,
}


spawn_enemies:: proc() {
    enemy_count :: 3
    enemies: [enemy_count]Enemy
    enemy_padding := 10
    enemy_y := 10
    //TODO:spawn enemies moving from side to side
    //for i in 0..<enemy_count {
        //enemies[i] = Enemy {
         //   pos: rl.Vector2{rand.
        //}
        //enemy
    //}
}
is_direction_opposite :: proc(dir1: direction, dir2: direction) -> bool {
	if dir1 == .up && dir2 == .down || dir1 == .down && dir2 == .up {
		return true
	} else if dir1 == .left && dir2 == .right || dir2 == .left && dir1 == .right {
		return true
	}

	return false
}

calc_hero_velocity :: proc(hero: Hero, direction: direction) -> (new_velocity: f32) {
	is_dir_opposite := is_direction_opposite(direction, hero.move_direction)
	if is_dir_opposite {
		new_velocity = 0
	} else {
		new_velocity = math.min(
			hero.movespeed + (hero.movespeed * hero.move_acceleration),
			HERO_MOVESPEED_MAX,
		)
	}

	return
}


move_entity :: proc(hero: ^Hero, direction: direction, velocity: f32) {
	hero.move_velocity = velocity
	hero.move_direction = direction

	delta := rl.GetFrameTime()
	switch direction {
	case .up:
		new_pos_y := clamp(hero.pos_y - velocity * delta, 0.0, f32(rl.GetScreenHeight()))
		hero.pos_y = new_pos_y
	case .down:
		hero.pos_y = clamp(hero.pos_y + velocity * delta, 0, f32(rl.GetScreenHeight()))
	case .left:
		hero.pos_x = clamp(hero.pos_x - velocity * delta, 0, f32(rl.GetScreenWidth()))
	case .right:
		hero.pos_x = clamp(hero.pos_x + velocity * delta, 0, f32(rl.GetScreenWidth()))

	case .None:
		fmt.println("stopped")

	}
}


draw_entity :: proc(hero: ^Hero, shape: rl.Rectangle) {
	rl.DrawRectangleRec({hero.pos_x, hero.pos_y, hero.width, hero.height}, COLOR_RED)

	if mode == .debug {
		rl.DrawLine(
			c.int(hero.pos_x + (hero.width / 2)),
			c.int(hero.pos_y),
			c.int(hero.look_direction[0]),
			c.int(hero.look_direction[1]),
			COLOR_RED,
		)
	}
}
// -------------------------------- DEBUG -------------------------------------
draw_terminal :: proc(x: f32, y: f32) {
	rect := rl.Rectangle{x, y, 300, 300}
	title: cstring = "terminal"
	terminal_window := rl.GuiWindowBox(rect, title)
	rl.DrawText("text", 0, 300, 21, {255, 0, 0, 255})
}

debug_info_on_screen :: proc(x, y: i32, text: cstring) {
	rl.DrawText(rl.TextFormat(text), x, y, 20, COLOR_RED)
}

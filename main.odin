package main
import fmt "core:fmt"
import math "core:math"
import os "core:os"
import strconv "core:strconv"
import strings "core:strings"
import "core:terminal"
import rl "vendor:raylib"

HERO_DEFAULT_WIDTH :: 1000.0
mode :: enum {
	debug,
}
HERO_DEFAULT_HEIGHT :: 1000.0
COLOR_RED :: rl.Color{255, 0, 0, 255}
HERO_MOVESPEED_MAX :: 50
WINDOW_HEIGHT :: 720
WINDOW_WIDTH :: 1280

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT})
	rl.SetTargetFPS(144)
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "D2RENA")

	hero := new_hero(
		width = 2000.0,
		height = 2000.0,
		pos_x = 0,
		pos_y = 360,
		movespeed = 10,
		move_velocity = 0,
		move_acceleration = .2,
		move_direction = nil,
		weight = 2,
	)

	for !rl.WindowShouldClose() {
		hero_moved_last_frame := hero.moved_this_frame
		//defer hero.moved_this_frame = false
		x := hero.pos_x
		y := hero.pos_y
		delta := rl.GetFrameTime()
        if rl.IsKeyDown(.LEFT) {
            direction := direction.left
            new_hero_velocity := calc_hero_velocity(hero, direction)
            move_entity(&hero, .left, new_hero_velocity)
            hero.moved_this_frame = true
        }

        if rl.IsKeyDown(.RIGHT) {
            direction := direction.right
            new_hero_velocity := calc_hero_velocity(hero, direction)
            hero.move_velocity = new_hero_velocity
            move_entity(&hero, .right, new_hero_velocity)
            hero.moved_this_frame = true
        }
        hero.pos_x = x
        hero.pos_y = y
        rect := rl.Rectangle{hero.pos_x, hero.pos_y, hero.width, hero.height}
        if hero_moved_last_frame && !hero.moved_this_frame {
            move_entity(&hero, hero.move_direction, f32(hero.weight))
        }
		rl.BeginDrawing()
		rl.ClearBackground({150, 190, 220, 255})
		top_y := rl.GetScreenHeight()

		//draw_terminal(0, f32(top_y) - 300)


		//tmpBuf :[]byte
		//debug_text := strings.concatenate({"X: ", strconv.write_int(tmpBuf[:], i64(x), 10), "Y: ", strconv.write_int(tmpBuf[:], i64(y), 10)})
		//debug_info_on_screen(0, 360, strings.clone_to_cstring(debug_text))

		fmt.println("X: ")
		fmt.println(x)
		fmt.println("Y")
		fmt.println(y)

		//camera := rl.Camera2D{}

		//rl.BeginMode2D(camera)
		rl.DrawRectangleRec({hero.pos_x, hero.pos_y, 50, 6}, COLOR_RED)
		//rl.EndMode2D()
		if hero_moved_last_frame && !hero.moved_this_frame {

		}
		hero.moved_this_frame = false
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
	look_direction:    [2]rl.Vector2,
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
	look_direction: [2]rl.Vector2 = {rl.Vector2{1, 1}, rl.Vector2{1, 1}},
	move_direction: direction = direction.None,
	move_acceleration: f32 = .2,
	weight: int,
) -> Hero {

	if movespeed > HERO_MOVESPEED_MAX {
		fmt.println("Error: hero speed cant be more than max speed")
		os.exit(1)
	}

	return Hero {
		width = width,
		height = height,
		pos_x = pos_x,
		pos_y = pos_y,
		movespeed = movespeed,
		move_velocity = move_velocity,
		look_direction = look_direction,
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


calc_entity_position :: proc(pos_x: f32, pos_y: f32, velocity: f32) -> (x: f32, y: f32) {
	return
}


move_entity :: proc(hero: ^Hero, direction: direction, velocity: f32) {
	hero.move_velocity = velocity
    fmt.println("Velocity:")
    fmt.println(velocity)
	switch direction {
	case .up:
		new_pos_y := clamp(hero.pos_y + velocity, 0.0, f32(rl.GetScreenHeight()))
		hero.pos_y = new_pos_y
	case .down:
		hero.pos_y = clamp(hero.pos_y + velocity, 0, f32(rl.GetScreenWidth()))
	case .left:
		hero.pos_x = clamp(hero.pos_x - velocity, 0, f32(rl.GetScreenWidth()))
	case .right:
		hero.pos_x = clamp(hero.pos_x + velocity, 0, f32(rl.GetScreenWidth()))

	case .None:
		fmt.println("stopped")
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

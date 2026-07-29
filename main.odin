#+feature dynamic-literals
package main
import c "core:c"
import fmt "core:fmt"
import math "core:math"
import rl "vendor:raylib"
import mem "core:mem"

imode :: enum {
	debug,
}
COLOR_RED :: rl.Color{255, 0, 0, 255}
WINDOW_HEIGHT :: 720
WINDOW_WIDTH :: 1280
mode := imode.debug

main :: proc() {
    tracking_allocator : mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) {
        for key, value in a.allocation_map {
            fmt.printf("%v: leaked %v bytes \n", value.location, value.size)
        }
        mem.tracking_allocator_clear(a)
    }

    defer reset_tracking_allocator(&tracking_allocator)



	rl.SetConfigFlags({.VSYNC_HINT})
	rl.SetTargetFPS(144)

	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, cstring("D2RENA"))

	hero := new_hero(
		width = 100.0,
		height = 100.0,
		pos_x = 0,
		pos_y = 360,
		movespeed = 370,
		move_velocity = 0,
		move_acceleration = .2,
		move_direction = nil,
		weight = 2,
	)
	enemies := create_enemies(3)

	camera := rl.Camera2D{} //


	for !rl.WindowShouldClose() {
		//------------------------LOGIC------------------------------------
		hero_moved_last_frame := hero.moved_this_frame
		hero.moved_this_frame = false

		//defer hero.moved_this_frame = false
		x := hero.pos_x
		y := hero.pos_y


		new_hero_velocity: f32
		rl.SetTraceLogLevel(.DEBUG)
		//keyStr: cstring


		//rl.TraceLog(rl.TraceLogLevel.DEBUG, keyStr)

        dir := direction.None

        if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
            dir = .up
            hero.moved_this_frame = true
        } else if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
            dir = .left
            hero.moved_this_frame = true
        } else if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
            dir = .right
            hero.moved_this_frame = true
        } else if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
            dir = .down
            hero.moved_this_frame = true
        }




        new_hero_velocity = calc_hero_velocity(hero, dir)
		move_entity(&hero, dir, new_hero_velocity, &camera)
		rect := rl.Rectangle{hero.pos_x, hero.pos_y, hero.width, hero.height}

		if hero_moved_last_frame && !hero.moved_this_frame {
			move_entity(&hero, hero.move_direction, f32(hero.weight), &camera)
		}

		// \\ ------------------------LOGIC END------------------------------


		//-----------------------RENDERING-----------------------------------
		rl.BeginDrawing()
		rl.DrawFPS(5, 5)
		rl.ClearBackground({150, 190, 220, 255})

		//drawing entities
		draw_entity(&hero, rect)
		draw_enemies_moving_from_side_to_side(enemies)
		//\\drawing entities

		rl.BeginMode2D(camera)
		rl.EndMode2D()


		rl.EndDrawing()
		// \\ ------------------END RENDERING---------------------------------
	}

	rl.CloseWindow()
}


/// ------------------------------------------ HERO -------------------------


draw_enemies_moving_from_side_to_side :: proc(enemies: []Enemy) {
	for enemy in enemies {
		cos := math.cos(rl.GetTime())
		x := f32(cos * WINDOW_WIDTH / 2) + WINDOW_WIDTH / 2 - enemy.width //TODO: add moving with enemy speed - now speed is static and stable
		pos := enemy.pos
		posP := &pos
		posP[0] = x
		rl.DrawCircleV(pos, enemy.width, COLOR_RED)
	}
}

keyboard_move_key_to_direction_map := map[rl.KeyboardKey]direction {
    .UP = .up,
    .DOWN = .down,
    .LEFT = .left,
    .RIGHT = .right,

    .W = .up,
    .S = .down,
    .A = .left,
    .D = .right,

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


move_entity :: proc(hero: ^Hero, direction: direction, velocity: f32, camera: ^rl.Camera2D) {
	hero.move_velocity = velocity
	hero.move_direction = direction

	delta := rl.GetFrameTime()
	new_x := hero.pos_x
	new_y := hero.pos_y
	switch direction {
	case .up:
		new_y = clamp(hero.pos_y - velocity * delta, 0.0, f32(rl.GetScreenHeight()))
		y_diff := hero.pos_y - new_y
	case .down:
		new_y = clamp(hero.pos_y + velocity * delta, 0, f32(rl.GetScreenHeight()))
		y_diff := hero.pos_y - new_y
	case .left:
		new_x = clamp(hero.pos_x - velocity * delta, 0, f32(rl.GetScreenWidth()))
		x_diff := hero.pos_x - new_x
	case .right:
		new_x = clamp(hero.pos_x + velocity * delta, 0, f32(rl.GetScreenWidth()))
		x_diff := hero.pos_x - new_x
	case .None:
		fmt.println("stopped")
	}
	hero.pos_y = new_y
	hero.pos_x = new_x
	ct := &camera.target
	ct[0] = hero.pos_x
	ct[1] = hero.pos_y
	ct.x = hero.pos_x
	ct.y = hero.pos_y
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

package main
import rl "vendor:raylib"
import "core:terminal"
import  math "core:math"
import fmt "core:fmt"
import os "core:os"

HERO_DEFAULT_WIDTH :: 1000.0
mode :: enum {
    debug
}
HERO_DEFAULT_HEIGHT :: 1000.0
COLOR_RED :: rl.Color{255, 0, 0, 255}
HERO_MOVESPEED_MAX :: 300
WINDOW_HEIGHT :: 720
WINDOW_WIDTH :: 1280

main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    rl.SetTargetFPS(144)
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "D2RENA")

    hero := new_hero (
        width = HERO_DEFAULT_WIDTH,
        height = HERO_DEFAULT_HEIGHT,
        pos_x = 0,
        pos_y = 360,
        movespeed = 200,
        move_velocity = 0,
        move_acceleration = .2
    )

    for !rl.WindowShouldClose() {
        delta := rl.GetFrameTime()
        rl.BeginDrawing()
        rl.ClearBackground({150, 190, 220, 255})
        top_y := rl.GetScreenHeight()
        draw_terminal(0, f32(top_y) - 300)
        x, y : f32

        if rl.IsKeyDown(.LEFT) {
            direction := direction.left
            new_hero_velocity := calc_hero_velocity(hero, direction)
            hero.move_velocity = new_hero_velocity
            x, y = calc_entity_position(hero.pos_x, hero.pos_y, hero.move_velocity)
        }

        if rl.IsKeyDown(.RIGHT) {
            direction := direction.right
            new_hero_velocity := calc_hero_velocity(hero, direction)
            hero.move_velocity = new_hero_velocity
            x, y = calc_entity_position(hero.pos_x, hero.pos_y, hero.move_velocity)
        }

        hero.pos_x += x
        hero.pos_y += y

        rect := rl.Rectangle{
            hero.pos_x, hero.pos_y,
            hero.width, hero.height
        }

        //camera := rl.Camera2D{}

        //rl.BeginMode2D(camera)
        rl.DrawRectangleRec(
            {hero.pos_x, hero.pos_y, 50, 6},
            COLOR_RED
        )
        //rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}


/// ------------------------------------------ HERO -------------------------
Hero :: struct {
    width:  f32,
    height: f32,
    pos_x:  f32,
    pos_y:  f32,
    movespeed: f32,
    move_velocity: f32,
    look_direction: [2]rl.Vector2,
    move_direction: direction,
    move_acceleration: f32,
}

new_hero :: proc (
    width: f32,
    height: f32,
    pos_x: f32,
    pos_y: f32,
    movespeed: f32 = 10,
    move_velocity: f32 = 10,
    look_direction: [2]rl.Vector2 = {rl.Vector2{1,1} , rl.Vector2{1,1}},
    move_direction: direction = direction.None,
    move_acceleration: f32 = .2
) -> Hero {

    if movespeed > HERO_MOVESPEED_MAX {
        fmt.println("Error: hero speed cant be more than max speed")
        os.exit(1)
    }

    return Hero {
        width, height, pos_x, pos_y, movespeed, move_velocity,
        look_direction, move_direction, move_acceleration
    }
}

direction ::  enum  {
    up, down, left, right, None
}

is_direction_opposite :: proc(dir1: direction, dir2: direction) -> (bool ) {
    if dir1 == .up && dir2 == .down  || dir1 == .down && dir2 == .up {
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
        new_velocity = math.min(hero.movespeed + (hero.movespeed * hero.move_acceleration), HERO_MOVESPEED_MAX)
    }

    return
}


calc_entity_position :: proc(pos_x: f32, pos_y: f32,  velocity: f32) -> (x: f32, y: f32) {
    x = clamp(pos_x + velocity, 0.0, f32(rl.GetScreenWidth()))
    y = clamp(pos_y + velocity, 0.0, f32(rl.GetScreenHeight()))
    return
}


draw_terminal :: proc (x :f32, y: f32) {
    rect := rl.Rectangle{x, y, 300, 300}
    title : cstring = "terminal"
    terminal_window := rl.GuiWindowBox(rect, title)
    rl.DrawText("text", 0, 300, 21, {255, 0, 0, 255})
}

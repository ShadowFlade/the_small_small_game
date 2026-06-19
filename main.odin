package main
import rl "vendor:raylib"

HERO_DEFAULT_WIDTH :: 1000.0
HERO_DEFAULT_HEIGHT :: 1000.0
COLOR_RED :: rl.Color{255, 0, 0, 255}
main :: proc() {
    rl.SetConfigFlags({.VSYNC_HINT})
    WINDOW_HEIGHT :: 720
    WINDOW_WIDTH :: 1280
    rl.SetTargetFPS(144)
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "D2RENA")

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        rl.ClearBackground({150, 190, 220, 255})

        hero := new_hero (
            HERO_DEFAULT_WIDTH,
            HERO_DEFAULT_HEIGHT,
            0,
            360
        )


        //if rl.IsKeyDown(.LEFT) {
         //   hero.
        //}
        rect := rl.Rectangle{
            hero.x_pos, hero.y_pos,
            hero.width, hero.height
        }

        camera := rl.Camera2D{
            zoom = 30.0
        }

        rl.BeginMode2D(camera)
        rl.DrawRectangleRec(
            {0, 260, 50, 6},
            COLOR_RED
        )
        rl.EndMode2D()
		rl.EndDrawing()
	}

	rl.CloseWindow()
}


Hero :: struct {
    width:  f32,
    height: f32,
    x_pos:  f32,
    y_pos:  f32,
    movespeed: f32,
    move_velocity: f32,
}

new_hero :: proc (width: f32, height: f32, x_pos: f32, y_pos: f32, movespeed: f32 = 10, move_velocity: f32 = 10) -> Hero {
    return Hero {
        width, height, x_pos, y_pos, movespeed, move_velocity
    }
}

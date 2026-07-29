package main
import rl "vendor:raylib"
import "core:os"
import "core:fmt"
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
	pos:          rl.Vector2,
	movespeed:    f16,
	velocity:     f16,
	acceleration: f16,
	health:       int,
	width:        f32,
}


create_enemies :: proc(count: int) -> []Enemy {
	enemies := make([]Enemy, count)
	enemy_padding: f32 = 100
	enemy_y: f32 = 20

	for i in 0 ..< count {
		rand_number := clamp(rand.float32() * 3000, 0.0, f32(rl.GetScreenWidth()))
		fmt.println(rand_number)
		enemies[i] = Enemy {
			pos          = rl.Vector2{rand_number, enemy_y},
			movespeed    = 50,
			velocity     = 200,
			acceleration = .2,
			health       = 100,
			width        = 30,
		}
		enemy_y += enemy_padding
	}

	return enemies
}
GameMemory :: struct {
	player:          Hero,
	enemies:         []Enemy,
	timeElapsed:     i64,
	realTimeElapsed: i64,
}

HERO_MOVESPEED_MAX :: 500
HERO_DEFAULT_HEIGHT :: 100.0
HERO_DEFAULT_WIDTH :: 100.0
@(export)
game_init :: proc() -> rawptr {
	mem := new(GameMemory)
	mem.player = new_hero(
		width = HERO_DEFAULT_WIDTH,
		height = HERO_DEFAULT_HEIGHT,
		pos_x = (WINDOW_WIDTH / 2) - (HERO_DEFAULT_WIDTH / 2),
		pos_y = (WINDOW_HEIGHT / 1.5),
		movespeed = HERO_MOVESPEED_MAX / 2,
        weight = 10,
	)
	return &""
}

package keys
move_key :: enum {
	D = rl.KeyboardKey.D,
	A = rl.KeyboardKey.A,
	S = rl.KeyboardKey.S,
	W = rl.KeyboardKey.W,
	UP = rl.KeyboardKey.UP,
	DOWN = rl.KeyboardKey.DOWN,
	LEFT = rl.KeyboardKey.LEFT,
	RIGHT = rl.KeyboardKey.RIGHT,
}

keyboard_move_key_to_direction_map := map[move_key]direction {
	rl.KeyboardKey.D     = direction.right,
	rl.KeyboardKey.A     = direction.left,
	rl.KeyboardKey.S     = direction.down,
	rl.KeyboardKey.W     = direction.up,
	rl.KeyboardKey.UP    = direction.up,
	rl.KeyboardKey.DOWN  = direction.down,
	rl.KeyboardKey.LEFT  = direction.left,
	rl.KeyboardKey.RIGHT = direction.right,
}

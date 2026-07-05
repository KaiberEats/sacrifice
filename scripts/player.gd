extends CharacterBody2D
# Player movement controller: ground/air acceleration+friction, split-gravity
# jump (GDD §3.2), coyote time, jump buffer, variable jump height. Every feel
# number comes from `config` (PlayerConfig) — no hardcoded movement/jump
# numbers here (CLAUDE.md rule 2). Gravity is fixed downward this step: no
# gravity-flip, no Sacrifice hookup (that is later steps' scope).

@export var config: PlayerConfig
@export var sprite_path: NodePath = ^"AnimatedSprite2D"

var _sprite: AnimatedSprite2D
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_right: bool = true
var _current_animation: String = ""


func _ready() -> void:
	if config == null:
		config = PlayerConfig.new()
	_sprite = get_node(sprite_path) as AnimatedSprite2D


func _physics_process(delta: float) -> void:
	# Split-gravity: rising and falling each get their own derived gravity so
	# jump arcs can be tuned via height/time rather than raw acceleration.
	var gravity_rise: float = (2.0 * config.jump_height) / (config.time_to_peak * config.time_to_peak)
	var gravity_fall: float = (2.0 * config.jump_height) / (config.time_to_fall * config.time_to_fall)
	var jump_velocity: float = (2.0 * config.jump_height) / config.time_to_peak

	_apply_horizontal_movement(delta)
	_apply_gravity(delta, gravity_rise, gravity_fall)
	_update_timers(delta)
	_handle_jump_input(jump_velocity)
	move_and_slide()
	_update_animation()


func _apply_horizontal_movement(delta: float) -> void:
	var input_dir: float = Input.get_axis("move_left", "move_right")
	var grounded: bool = is_on_floor()
	var target_speed: float = input_dir * config.move_speed
	var rate: float
	if input_dir != 0.0:
		rate = config.ground_acceleration if grounded else config.air_acceleration
		_facing_right = input_dir > 0.0
	else:
		rate = config.ground_friction if grounded else config.air_friction
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)


func _apply_gravity(delta: float, gravity_rise: float, gravity_fall: float) -> void:
	var g: float = gravity_fall if velocity.y >= 0.0 else gravity_rise
	velocity.y += g * delta
	velocity.y = min(velocity.y, config.max_fall_speed)


func _update_timers(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = config.coyote_time
	else:
		_coyote_timer = max(_coyote_timer - delta, 0.0)
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = config.jump_buffer_time
	else:
		_jump_buffer_timer = max(_jump_buffer_timer - delta, 0.0)


func _handle_jump_input(jump_velocity: float) -> void:
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
	elif Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= config.jump_cut_multiplier


func _update_animation() -> void:
	if _sprite == null:
		return
	var anim: String
	if is_on_floor():
		anim = "idle" if is_zero_approx(velocity.x) else "run"
	else:
		anim = "jump" if velocity.y < 0.0 else "fall"
	if anim != _current_animation:
		_current_animation = anim
		_sprite.play(anim)
	_sprite.flip_h = not _facing_right

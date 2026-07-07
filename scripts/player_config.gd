extends Resource
class_name PlayerConfig
# Player feel data (GDD §3.3). player.gd must read every movement/jump
# number from an instance of this resource — no hardcoded feel numbers
# in code (CLAUDE.md rule 2).

@export var move_speed: float = 180.0
@export var ground_acceleration: float = 1800.0
@export var ground_friction: float = 2200.0
@export var air_acceleration: float = 1200.0
@export var air_friction: float = 400.0
@export var jump_height: float = 64.0
@export var time_to_peak: float = 0.38
@export var time_to_fall: float = 0.30
@export var jump_cut_multiplier: float = 0.45
@export var max_fall_speed: float = 600.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

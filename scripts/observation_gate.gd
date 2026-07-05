extends StaticBody2D
# "Observation collapse" reactive gate (GDD §5.5, §8.6): solid while the
# tracked concept has NOT yet been permanently sacrificed (i.e. the status
# UI is still "observing"), passable once it has. Same reactive-object shape
# as blue_object.gd — copy this file and repoint concept_id to gate on a
# different permanent sacrifice. Never reference the HUD node directly, only
# Sacrifice's signal, so this stays usable in any level without wiring.

@export var concept_id: String = "hud"
@export var solid_alpha: float = 1.0
@export var passable_alpha: float = 0.35
@export var collision_shape_path: NodePath = ^"CollisionShape2D"
@export var visual_path: NodePath = ^"Visual"

var _collision_shape: CollisionShape2D
var _visual: CanvasItem


func _ready() -> void:
	_collision_shape = get_node_or_null(collision_shape_path) as CollisionShape2D
	_visual = get_node_or_null(visual_path) as CanvasItem
	Sacrifice.concept_permanently_sacrificed.connect(_on_permanently_sacrificed)
	_apply_state(Sacrifice.is_permanently_sacrificed(concept_id))


func _on_permanently_sacrificed(id: String) -> void:
	if id == concept_id:
		_apply_state(true)


func _apply_state(passable: bool) -> void:
	if _collision_shape:
		_collision_shape.set_deferred("disabled", passable)
	if _visual:
		var c: Color = _visual.modulate
		c.a = passable_alpha if passable else solid_alpha
		_visual.modulate = c

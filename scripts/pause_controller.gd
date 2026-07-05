extends CanvasLayer
# Real pause + the `pause` sacrifice (GDD §2.6). This node's process_mode is
# set to Always on the scene, so it keeps receiving input and stays
# interactive while get_tree().paused is true — every other node in the
# game (Player, SacrificeInput, Altars) defaults to Inherit and freezes
# automatically once paused, which is exactly what "real pause" needs, for
# free. Decoupled from HUD/altars: only touches
# Sacrifice.is_permanently_sacrificed("pause") and get_tree().paused.

@export var label_path: NodePath = ^"Label"

var _label: Label


func _ready() -> void:
	_label = get_node(label_path) as Label


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if get_tree().paused:
		_set_paused(false)
	elif not Sacrifice.is_permanently_sacrificed("pause"):
		_set_paused(true)


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_label.visible = paused

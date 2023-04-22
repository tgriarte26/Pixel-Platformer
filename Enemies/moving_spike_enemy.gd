@tool
extends Path2D

enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

@export var animation_type: ANIMATION_TYPE: set = set_animation_type
@export var speed: int: set = set_speed
@onready var animationPlayer: = $AnimationPlayer

func set_animation_type(value):
	animation_type = value
	var ap = get_node("AnimationPlayer")
	if ap:
		play_updated_animation(ap)
		
func set_speed(value):
	speed = value
	var ap = get_node("AnimationPlayer")
	if ap:
		ap.playback_speed = speed

func _ready():
	play_updated_animation(animationPlayer)
			
func play_updated_animation(ap):
	match animation_type:
		ANIMATION_TYPE.LOOP: ap.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: ap.play("MoveAlongPathBounce")

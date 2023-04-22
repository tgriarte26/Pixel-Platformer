extends CharacterBody2D

var direction = Vector2.RIGHT #(1, 0) * -1 = (-1, 0)
	
@onready var ledgeCheckRight: = $LedgeCheckRight
@onready var ledgeCheckLeft: = $LedgeCheckLeft
@onready var sprite = $AnimatedSprite2D

func _physics_process(delta):
	#checks if touching wall
	var found_wall = is_on_wall()
	var found_ledge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding()

	if found_wall or found_ledge:
		direction *= -1
	
	sprite.flip_h = direction.x > 0
		
	velocity = direction * 25
	move_and_slide()

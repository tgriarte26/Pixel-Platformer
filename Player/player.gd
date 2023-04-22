extends CharacterBody2D
class_name Player

enum { MOVE, CLIMB }
var state = MOVE
var buffered_jump = false
var coyote_jump = false
#per physics frame
#@export var JUMP_FORCE: int = -130
#@export var JUMP_RELEASE_FORCE = -70
#@export var MAX_SPEED = 50
#@export var ACCELERATION = 10
#@export var FRICTION = 10
#@export var GRAVITY = 4
#@export var ADDITIONAL_FALL_GRAVITY = 4

@export var moveData = Resource

#shortcut
@onready var animatedSprite = $AnimatedSprite2D

@export var see_ladder = false
@onready var ladderCheck = $LadderCheck
@onready var jumpBufferTimer = $JumpBufferTimer
@onready var coyoteJumpTimer = $CoyoteJumpTimer
@onready var remoteTransform2D = $RemoteTransform2D

var double_jump = 1

func _ready():
	animatedSprite.frames = load("res://Player/playerBlueSkin.tres")
	
func _physics_process(delta):
	if ladderCheck.is_colliding() and Input.is_action_pressed("ui_ladder"):
		see_ladder = true
	else:
		see_ladder = false
	
	if see_ladder == false:
		velocity.y += moveData.GRAVITY * delta
		velocity.y = min(velocity.y,500)
	if see_ladder == true:
		velocity.y = 0
		if Input.is_action_pressed("ui_up"):
			velocity.y -= moveData.MAX_SPEED
		if Input.is_action_pressed("ui_down"):
			velocity.y += moveData.MAX_SPEED
	var input = Vector2.ZERO
	#input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	move_state(input)

func move_state(input):
	apply_gravity()
	
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
	
		animatedSprite.flip_h = input.x > 0
#	#handles flipping
#	if input.x > 0:
#			animatedSprite.flip_h = true
#	elif input.x < 0:
#			animatedSprite.flip_h = false
		
#	if Input.is_action_pressed("ui_right"):
#		velocity.x = 50
#	elif Input.is_action_pressed("ui_left"):
#		velocity.x = -50
#	else:
#		velocity.x = 0
		
	if is_on_floor() or coyote_jump:
		#Reset double jump
		double_jump = moveData.DOUBLE_JUMP_COUNT
		#jump
		if Input.is_action_just_pressed("ui_up") or buffered_jump:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = moveData.JUMP_FORCE
			buffered_jump = false
	else:
		animatedSprite.animation = "Jump"
		
		#jump release height
		if Input.is_action_just_released("ui_up") and velocity.y < moveData.JUMP_RELEASE_FORCE:
			velocity.y = moveData.JUMP_RELEASE_FORCE
		
		#double jump
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			velocity.y = moveData.JUMP_FORCE
			double_jump -= 1
		
		#jump buffer
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			jumpBufferTimer.start()
		
		#fast fall
		if velocity.y > 0:
			velocity.y += moveData.ADDITIONAL_FALL_GRAVITY
			
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
	#get_tree().reload_current_scene()

#connect camera to remote transform	
func connect_camera(camera):
	var	camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func apply_gravity():
	velocity.y += moveData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)
	
func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

func _on_jump_buffer_timer_timeout():
	buffered_jump = false

func _on_coyote_jump_timer_timeout():
	coyote_jump = false

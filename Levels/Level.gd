extends Node2D

const PlayerScene = preload("res://Player/player.tscn")

var player_spawn_location = Vector2.ZERO

@onready var camera: = $Camera2D
@onready var player: = $Player
@onready var timer: = $Timer

func _ready():
	RenderingServer.set_default_clear_color(Color.CORNFLOWER_BLUE)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.player_died.connect(_on_player_died)
	Events.hit_checkpoint.connect(_on_hit_checkpoint)

#when player dies
func _on_player_died():
	timer.start(1.0)
	await timer.timeout
	var player = PlayerScene.instantiate()
	player.position = player_spawn_location
	#adds player as child of world
	get_parent().add_child(player)
	#reconnects camera
	player.connect_camera(camera)
	await get_tree().process_frame

func _on_hit_checkpoint(checkpoint_position):
	player_spawn_location = checkpoint_position


extends Node2D

var Room = preload("res://Scenes/Room.tscn")

var tile_size = 32
var num_rooms = 50
var min_size = 4
var max_size = 10
var h_spread = 400
var cull_percentage = 0.5

func _ready():
	randomize()
	make_rooms()

func make_rooms():
	for i in range(num_rooms):
		var pos = Vector2(rand_range(-h_spread, h_spread), 0)
		var room = Room.instance()
		var w = min_size + randi() % (max_size - min_size)
		var h = min_size + randi() % (max_size - min_size)
		room.make_room(pos, Vector2(w, h) * tile_size)
		$Rooms.add_child(room)
	# Wait for movement to stop
	yield(get_tree().create_timer(1.1), "timeout")
	
	for room in $Rooms.get_children():
		if randf() < cull_percentage:
			room.queue_free()

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(31, 215, 0), false)

func _process(delta):
	update()

func _input(event):
	if Input.is_action_pressed("ui_select"):
		for room in $Rooms.get_children():
			room.queue_free()
		make_rooms()

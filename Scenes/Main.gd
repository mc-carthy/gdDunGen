extends Node2D

var Room = preload("res://Scenes/Room.tscn")

var tile_size = 32
var num_rooms = 50
var min_size = 4
var max_size = 10
var h_spread = 400
var cull_percentage = 0.5
var path : AStar2D # minimum spanning tree

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
	
	var room_positions = []
	for room in $Rooms.get_children():
		if randf() < cull_percentage:
			room.queue_free()
		else:
			room.mode = RigidBody2D.MODE_STATIC
			room_positions.append(room.position)
	yield(get_tree(), "idle_frame")
	path = find_mst(room_positions)

func find_mst(nodes):
	var path : AStar2D = AStar2D.new()
	path.add_point(path.get_available_point_id(), nodes.pop_front())
	while nodes:
		var minimum_dist : float = INF
		var minimum_node_position : Vector2
		var current_checking_position : Vector2
		
		for point in path.get_points():
			point = path.get_point_position(point)
			for node in nodes:
				if point.distance_to(node) < minimum_dist:
					minimum_dist = point.distance_to(node)
					minimum_node_position = node
					current_checking_position = point
		var next_available_id : int = path.get_available_point_id()
		path.add_point(next_available_id, minimum_node_position)
		path.connect_points(path.get_closest_point(current_checking_position), next_available_id)
		nodes.erase(minimum_node_position)
	return path

func _draw():
	for room in $Rooms.get_children():
		draw_rect(Rect2(room.position - room.size, room.size * 2), Color(31, 215, 0), false)
	if path:
		for point in path.get_points():
			for neighbour in path.get_point_connections(point):
				var pos : Vector2 = path.get_point_position(point)
				var neighbour_pos : Vector2 = path.get_point_position(neighbour)
				draw_line(pos, neighbour_pos, Color(191, 0, 0))

func _process(delta):
	update()

func _input(event):
	if Input.is_action_pressed("ui_select"):
		for room in $Rooms.get_children():
			room.queue_free()
		make_rooms()

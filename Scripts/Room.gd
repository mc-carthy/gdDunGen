extends RigidBody2D

var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	var shape = RectangleShape2D.new()
	shape.extents = size
	shape.custom_solver_bias = 0.75
	$CollisionShape2D.shape = shape

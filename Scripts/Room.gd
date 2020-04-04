extends RigidBody2D

var size

func make_room(_pos, _size):
	position = _pos
	size = _size
	var shape = RectangleShape2D.new()
	shape.extents = size
	$CollisionShape2D.shape = shape

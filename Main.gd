extends CenterContainer

var path : PackedVector2Array
var alpha : float = 1
var finished : bool = false
var hit_circle : bool = false
var loop_complete : bool = false
var around_circle : bool = false
var unit_circle_points : PackedVector2Array
var levels_complete : int = 0
var failed : bool = true

signal game_completed


func _ready():
	unit_circle_points = get_unit_circle_points()


func get_2d_acceleration():
	var acceleration = Sensors.get_accelerometer()
	return Vector2(-acceleration.x, acceleration.y)


func _draw():
	if not path.is_empty():
		var color : Color
		if not finished:
			color = Color(1, 1, 1, alpha)
		elif failed:
			color = Color(1, 0, 0, alpha)
		else:
			color = Color(0, 1, 0, alpha)
		draw_circle(path[0], 10, color)
		draw_polyline(path, color, 2, false)


func get_unit_circle_points(num_pts = 100):
	var points : PackedVector2Array = []
	var angle : float
	var point : Vector2
	for i in range(num_pts):
		angle = i * TAU / num_pts
		point = Vector2(cos(angle), sin(angle))
		points.append(point)
	return points


func circle_inside_path(center, radius):
	var circle : PackedVector2Array
	for point in unit_circle_points:
		point = point * radius + center
		circle.append(point)
	var clip = Geometry2D.clip_polygons(circle, path)
	return clip.size() == 0
	


func _process(delta):
	if finished:
		alpha = max(alpha - delta/2, 0)
		queue_redraw()


func _physics_process(delta):
	if levels_complete > 0:
		var acceleration = get_2d_acceleration()
		$Control/Circle.apply_central_force(100 * acceleration)


func _input(event):
	if (event is InputEventScreenTouch):
		if event.pressed:
			finished = false
			hit_circle = false
			loop_complete = false
			alpha = 1
			path = [event.position]
			$Mouse.position = event.position
			$StartPoint.position = event.position
		else:
			finished = true
			var shape = $Control/Circle/CollisionShape2D
			around_circle = circle_inside_path(shape.global_position, shape.shape.radius)
			failed = hit_circle or (not loop_complete) or (not around_circle)
			if not failed:
				levels_complete += 1
				if levels_complete == 2:
					game_completed.emit()
		queue_redraw()
	elif event is InputEventScreenDrag:
		$Mouse.position = event.position
		path.append(event.position)
		queue_redraw()


func _on_mouse_body_entered(body):
	if body == $Control/Circle:
		hit_circle = true


func _on_start_point_area_entered(area):
	if path.size() > 10:
		loop_complete = true


func _on_game_completed():
	var alpha : float
	var modulate = $CanvasLayer/CanvasModulate
	modulate.color = Color(1, 1, 1, 0)
	var ending = $CanvasLayer/EndingMessage
	ending.get_node("PanelContainer").visible = true
	await get_tree().create_timer(1).timeout
	var num_pts : int = 50
	for i in range(1, num_pts + 1):
		alpha = i / float(num_pts)
		modulate.color = Color(1, 1, 1, alpha)
		await get_tree().create_timer(2/float(num_pts)).timeout
	ending.scroll()

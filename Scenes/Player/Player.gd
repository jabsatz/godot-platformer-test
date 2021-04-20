extends KinematicBody2D

export (int) var max_speed = 400
export (int) var wall_jump_h_speed = 600
export (int) var acceleration = 50
export (int) var jump_speed = -600
export (int) var gravity = 1200
export (int) var wall_climb_gravity = 600

var velocity = Vector2()
var jumping = false
var can_second_jump = true

onready var _animated_sprite = $AnimatedSprite

var was_on_wall = false
var was_on_floor = false

var acme_time_limit = 3
var acme_time = 0
var acme_time_type = null
var acme_time_data = {}


func update_acme_time():
	if acme_time_type == null:
		if not was_on_floor and is_on_floor():
			was_on_floor = true
		if not was_on_wall and is_on_wall() and not is_on_floor():
			was_on_wall = true

		if was_on_floor and not is_on_floor():
			acme_time_type = 'floor'
		if was_on_wall and not is_on_wall():
			acme_time_type = 'wall'
			var isRightSide = velocity.x < 0
			acme_time_data.isRightSide = isRightSide
	else:
		if acme_time > acme_time_limit:
			was_on_floor = false
			was_on_wall = false
			acme_time_type = null
			acme_time_data = {}
			acme_time = 0
		else:
			acme_time += 1


func is_on_acme_time():
	return acme_time_type != null


func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	if left or right:
		if right and velocity.x < max_speed:
			velocity.x += acceleration
		elif left and velocity.x > -max_speed:
			velocity.x -= acceleration
		elif right:
			velocity.x = max_speed
		elif left:
			velocity.x = -max_speed
		$AnimatedSprite.flip_h = left
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - acceleration, 0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + acceleration, 0)

	if jump and (is_on_floor() or is_on_wall() or is_on_acme_time() or can_second_jump):
		jumping = true
		if (is_on_wall() and not is_on_floor()) or acme_time_type == 'wall':
			var shouldGoRight = false
			if acme_time_type == 'wall':
				shouldGoRight = not acme_time_data.isRightSide
			else:
				shouldGoRight = $AnimatedSprite.flip_h

			if shouldGoRight:
				velocity.x += wall_jump_h_speed
			else:
				velocity.x -= wall_jump_h_speed
		var is_second_jump = not is_on_floor() and not is_on_wall() and not is_on_acme_time()
		if is_second_jump:
			can_second_jump = false
		velocity.y = jump_speed


func get_animation():
	var new_animation
	if is_on_wall() and not is_on_floor():
		new_animation = 'WallJump'
	elif velocity.y != 0 and not can_second_jump:
		new_animation = 'DoubleJump'
	elif velocity.y < 0:
		new_animation = 'Jump'
	elif velocity.y > 0:
		new_animation = 'Fall'
	elif velocity.x != 0:
		new_animation = 'Run'
	else:
		new_animation = 'Idle'
	$AnimatedSprite.play(new_animation)


func _physics_process(delta):
	update_acme_time()
	get_input()
	get_animation()

	if is_on_wall() and velocity.y > 0:
		velocity.y += wall_climb_gravity * delta
	else:
		velocity.y += gravity * delta

	if is_on_floor() or is_on_wall():
		can_second_jump = true
		if jumping:
			jumping = false

	velocity = move_and_slide(velocity, Vector2(0, -1))

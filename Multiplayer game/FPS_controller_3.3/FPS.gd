extends KinematicBody

var speed = 10
var ACCEL_DEFAULT = 9
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT
var gravity = 13
var jump = 6

var cam_accel = 40
var mouse_sense = 0.1
var snap

var jump_num = 0

onready var ground_check2 = $Groundcheck2
onready var ground_check = $Groundcheck
onready var Ap = $AnimationPlayer


var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false

onready var grapplecast = $Head/Camera/GrappleCast

onready var chest_ray = $Rays/forwardray
onready var head_ray = $Rays/Top


var is_wallrunning = false

var is_running = false
var is_sliding = false

var Jump_pad_force = 10

var can_slide = false

var can = false

var w_runnable = false

var can_jump = false

var wall_normal

var can_climb = false

var direction = Vector3()
var velocity = Vector3()
var gravity_vec = Vector3()
var movement = Vector3()

onready var label = $Head/Camera/UI/Label

onready var head = $Head
onready var camera = $Head/Camera

var can_move = true

var can_it_climb = true

var wall_running = false

var time : float = 0.0

var timer_on = false


var is_moving = false


func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)



func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))


func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
	

func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("back") - Input.get_action_strength("forward")
	var h_input = Input.get_action_strength("right") - Input.get_action_strength("left")
	if can_move:
		direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
		
	
	
	if Input.is_action_pressed("forward") and Input.is_action_just_pressed("crouch"):
		if is_on_floor():
			velocity += direction * 7000 * delta
			camera.fov = 100
			ACCEL_DEFAULT = 7
		else:
			camera.fov = 90
			ACCEL_DEFAULT = 9
		
	if Input.is_action_just_released("Run"):
		is_running = false
		
	if is_moving == true:
		timer_on = true
	
	

	if Input.is_action_pressed("Run") and speed == 10 and is_running == false and is_on_floor() and direction != Vector3.ZERO:
		is_running = true
		camera.fov = 95
		speed = 17

	elif is_running == false:
		speed = 10
		camera.fov = 90
	
	
	is_moving()
	#grapple()
	
	
	
	#jumping and gravity
	if is_on_floor():
		jump_num = 0
		snap = -get_floor_normal()
		accel = ACCEL_DEFAULT
		gravity_vec = Vector3.ZERO
		w_runnable = false
		can_climb = false
		wall_running = false
	else:
		snap = Vector3.DOWN
		accel = ACCEL_AIR
		gravity_vec += Vector3.DOWN * gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if jump_num == 0:
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
			jump_num = 1
			
	if Input.is_action_just_pressed("jump") and !is_on_floor() and can_climb == false:
		if jump_num == 1 or jump_num == 0:
			snap = Vector3.ZERO
			gravity_vec = Vector3.UP * jump
			jump_num = 2
	
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	movement = velocity + gravity_vec
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)



func is_moving():
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back") or Input.is_action_pressed("left") or Input.is_action_pressed("right") or Input.is_action_pressed("jump"):
		is_moving = true


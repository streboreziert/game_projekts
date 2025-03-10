extends Sprite2D
var m_to_px = 100 # 1m = 100 px

var turn_radius = 12
#var turn_time = 0.5
#var turning = 0

var mass = 1500.0

var speed = 0
var engine_power = 200
var tire_grip = 0.4
var braking_deceleration = 10

var reverse_gear = 15

var acceleration = 0
var acceleration_time = 2

signal data(speed)
var debug = ""

#func _init() -> void:
	#var x_size = 227
	#var y_size = 500
	
func new_speed(rolling, drag, braking, power, delta):
	var kinetic_energy = (mass * abs(speed) ** 2)/2.0
	
	
	
	if (kinetic_energy + (power - drag * abs(speed) - rolling*abs(speed)) * delta) - braking * delta < 0:
		return 0
	else:
		return (sqrt( (2.0/mass) * (kinetic_energy + (power - drag * abs(speed) - rolling*abs(speed)) * delta)) - braking * delta)

func speed_change(delta, input):
	var speed_old = speed
	var air_density = 1.2
	var drag_area = 1.5
	var rolling_coef = 0.015
	var drag = (0.5 * drag_area * air_density * speed ** 2)
	var rolling_resistance = rolling_coef * mass * 10
	
	var power = 0
	
	var braking_force = 0
	
	if speed * input > 0:
		power = engine_power * 1000
		
	if speed * input < 0:
		braking_force = braking_deceleration
	
	if speed == 0 and input != 0:
		power = engine_power
		speed = input * new_speed(rolling_resistance,drag,braking_force,power,delta)
		
		if (speed-speed_old)/delta > 10:
			speed = speed_old + 10 * delta
	else:
		var dir = 0
		if speed > 0:
			dir = 1
		if speed < 0:
			dir = -1
	
		speed = dir * new_speed(rolling_resistance,drag,braking_force,power,delta)
	
	if (speed-speed_old)/delta > 10:
		speed = speed_old + 10 * delta
	
func rotation_change(turn, delta):
	var ang_rot = speed*m_to_px / (turn_radius * 2 * PI)
	#if turning < 1:
		#turning += delta / turn_time
	rotation += 2 * PI * ang_rot * delta * turn

func _process(delta: float) -> void:
	debug = ""
	var direction = Vector2.UP.rotated(rotation) * speed * m_to_px
	
	position += direction
	
	var gas = 0
	if Input.is_action_pressed("ui_up"):
		gas = 1
	if Input.is_action_pressed("ui_down"):
		gas = -1
	speed_change(delta, gas)
	
	
	var turn = 0
	if Input.is_action_pressed("ui_right"):
		turn = 1
	if Input.is_action_pressed("ui_left"):
		turn = -1
	rotation_change(turn, delta)
	data.emit(speed*3.6)
	
	print(debug)

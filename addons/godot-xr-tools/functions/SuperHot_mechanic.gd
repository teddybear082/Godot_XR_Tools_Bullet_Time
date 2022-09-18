extends Node

##This script creates a "SuperHot" time only moves when you move mechanic. Add it to a node in a scene to have it take effect.

## Activate overall mechanic or not
export var active := true

## Set slomo lerp scale 
export var slo_mo_ease := 20

## Slomo time scale (percentage of engine speed)
export var slowmo_time_scale := .05
## Normal time sclae
export var normal_time_scale = 1.0

## Hand and Camera nodepaths
export (NodePath) var arvrcamera_path  = ""
export (NodePath) var left_hand_path = ""
export (NodePath) var right_hand_path = ""



## Hand and camera nodes
onready var l_hand_node = get_node(left_hand_path)
onready var r_hand_node = get_node(right_hand_path)
onready var arvrcamera_node = get_node(arvrcamera_path)


## Determine if slowmo itself is currently active
var slomo = false

## Arbitrary Threshold to determine if enough movement to move time (in units of movement)
var slowmo_threshold : float = .005

## Variables used for tracking current and last positions of head and hands
var l_hand_position : Vector3 = Vector3.ZERO
var r_hand_position : Vector3 = Vector3.ZERO
var arvrcamera_position : Vector3 = Vector3.ZERO
var last_l_hand_position : Vector3 = Vector3.ZERO
var last_r_hand_position : Vector3 = Vector3.ZERO
var last_arvrcamera_position : Vector3 = Vector3.ZERO
var time_elapsed_in_msecs : float = 0.0
var current_time_in_msecs : float = 0.0
var last_time_in_msecs : float = 0.0

## Tell other nodes when slomo is active or not
signal slomo_active
signal slomo_off

func _ready():
	l_hand_position = l_hand_node.global_transform.origin
	r_hand_position = r_hand_node.global_transform.origin
	arvrcamera_position = arvrcamera_node.global_transform.origin
	last_l_hand_position = l_hand_node.global_transform.origin
	last_r_hand_position = r_hand_node.global_transform.origin
	last_arvrcamera_position = arvrcamera_node.global_transform.origin
	current_time_in_msecs = OS.get_ticks_msec()
	last_time_in_msecs = current_time_in_msecs

# Main handling of slomo
func _physics_process(delta):
	if time_elapsed() >= 10.0:
		last_time_in_msecs = OS.get_ticks_msec()
		slomo = calc_slomo()
	
	# If player's movement is not past movement threshold, slomo stays in effect, otherwise moves to normal time scale
	if slomo:
		#emit_signal("slomo_active")
		Engine.time_scale = lerp(Engine.time_scale, slowmo_time_scale, delta * slo_mo_ease)
	
	else:
		#emit_signal("slomo_off")
		Engine.time_scale = lerp(Engine.time_scale, normal_time_scale, delta * slo_mo_ease)		
	
func time_elapsed() -> float:
	current_time_in_msecs = OS.get_ticks_msec()
	time_elapsed_in_msecs = current_time_in_msecs - last_time_in_msecs
	return time_elapsed_in_msecs
	
func calc_slomo() -> bool:
	l_hand_position = l_hand_node.global_transform.origin
	r_hand_position = r_hand_node.global_transform.origin
	arvrcamera_position = arvrcamera_node.global_transform.origin
	if (l_hand_position - last_l_hand_position).length() + (r_hand_position-last_r_hand_position).length() + (arvrcamera_position - last_arvrcamera_position).length() < slowmo_threshold:
		last_l_hand_position = l_hand_position
		last_r_hand_position = r_hand_position
		last_arvrcamera_position = arvrcamera_position
		return true
	else:
		last_l_hand_position = l_hand_position
		last_r_hand_position = r_hand_position
		last_arvrcamera_position = arvrcamera_position
		return false

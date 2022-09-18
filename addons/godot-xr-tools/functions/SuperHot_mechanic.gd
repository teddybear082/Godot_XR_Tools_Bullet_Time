extends Node

##This script creates a "SuperHot" time only moves when you move mechanic. Add it to a node in a scene to have it take effect.

## Activate overall mechanic or not
export var active := true

## Set slomo lerp scale 
export var slo_mo_ease := 20

## Slomo time scale (percentage of engine speed)
export var slowmo_time_scale := .03

## Normal time sclae
export var normal_time_scale = 1.0

## set time to wait, in msec, before calculating slomo again
export var time_to_check_in_msec :float = 100.0

## Arbitrary Threshold to determine if enough movement to move time (in godot units)
var slowmo_threshold : float = .01

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

## Variables used for tracking current and last positions of head and hands
var l_hand_position : Vector3 = Vector3.ZERO
var r_hand_position : Vector3 = Vector3.ZERO
var arvrcamera_position : Vector3 = Vector3.ZERO
var last_l_hand_position : Vector3 = Vector3.ZERO
var last_r_hand_position : Vector3 = Vector3.ZERO
var last_arvrcamera_position : Vector3 = Vector3.ZERO
var time_elapsed_in_msecs : float = 0.0


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
	

# Main handling of slomo
func _physics_process(delta):
	
	#if time since last check is greater than 100 miliseconds in real time / .1 second, then recalculate whether should be in slomo
	if OS.get_ticks_msec() - time_elapsed_in_msecs >= time_to_check_in_msec:
		time_elapsed_in_msecs = OS.get_ticks_msec()	
		slomo = calc_slomo()
	
	# If player's movement is not past movement threshold, slomo stays in effect, otherwise moves to normal time scale
	if slomo:
		#emit_signal("slomo_active")
		Engine.time_scale = lerp(Engine.time_scale, slowmo_time_scale, delta * slo_mo_ease)
	
	else:
		#emit_signal("slomo_off")
		Engine.time_scale = lerp(Engine.time_scale, normal_time_scale, delta * slo_mo_ease)		
	
#calculate whether player's movement is enough to keep time moving or if player is steady  enough to stop time
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

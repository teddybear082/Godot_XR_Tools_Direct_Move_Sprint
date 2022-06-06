tool
class_name Function_DirectMovement
extends MovementProvider

##
## Movement Provider for Direct Movement
##
## @desc:
##     This script works with the Function_Direct_movement asset to provide
##     direct movement for the player. This script works with the PlayerBody
##     attached to the players ARVROrigin.
##
##     The following types of direct movement are supported:
##      - Slewing
##      - Forwards and backwards motion
##
##     The player may have multiple direct movement nodes attached to different
##     controllers to provide different types of direct movement.
##

enum SPRINT_TYPE { HOLD_TO_SPRINT, TOGGLE_SPRINT }
enum Buttons {
	VR_BUTTON_BY = 1,
	VR_GRIP = 2,
	VR_BUTTON_3 = 3,
	VR_BUTTON_4 = 4,
	VR_BUTTON_5 = 5,
	VR_BUTTON_6 = 6,
	VR_BUTTON_AX = 7,
	VR_BUTTON_8 = 8,
	VR_BUTTON_9 = 9,
	VR_BUTTON_10 = 10,
	VR_BUTTON_11 = 11,
	VR_BUTTON_12 = 12,
	VR_BUTTON_13 = 13,
	VR_PAD = 14,
	VR_TRIGGER = 15
}

## Movement provider order
export var order := 10

## Movement speed

export var default_speed := 4.0
export var sprint_speed := 7.0
var speed = default_speed

## Enable player strafing
export var strafe := false


## Can Sprint flag
export var canSprint := true

## Sprint activate button
export (Buttons) var sprint_button_id = Buttons.VR_PAD

## Choose type of sprinting - toggle or hold
export (SPRINT_TYPE) var sprint_type = SPRINT_TYPE.TOGGLE_SPRINT


# Controller node
onready var _controller : ARVRController = get_parent()

var is_sprinting = false
var button_states = []
# Perform direct movement
func physics_movement(delta: float, player_body: PlayerBody, _disabled: bool):
	# Skip if the controller isn't active
	if !_controller.get_is_active():  #TB Edit as bandaid for now to add "enabled == false"
		return
	
	# Implement sprinting toggle if selected
	if sprint_type == SPRINT_TYPE.TOGGLE_SPRINT:
	
		if canSprint and button_pressed(sprint_button_id):
			if is_sprinting == false: 
				is_sprinting = true
				speed = sprint_speed
				#print("sprinting now and speed = " + str(speed))
				#print(str(button_states))
	
			else:
				is_sprinting = false
				speed = default_speed
				#print("back to normal speed now and speed = " + str(speed))
				#print(str(button_states))
				
	# Implement hold sprint button if selected
	if sprint_type == SPRINT_TYPE.HOLD_TO_SPRINT:
		speed = default_speed
		
		if canSprint and _controller.is_button_pressed(sprint_button_id):
			speed = sprint_speed
			
	# Apply forwards/backwards ground control
	player_body.ground_control_velocity.y += _controller.get_joystick_axis(1) * speed

	# Apply left/right ground control
	if strafe:
		player_body.ground_control_velocity.x += _controller.get_joystick_axis(0) * speed

	# Clamp ground control
	player_body.ground_control_velocity.x = clamp(player_body.ground_control_velocity.x, -speed, speed)
	player_body.ground_control_velocity.y = clamp(player_body.ground_control_velocity.y, -speed, speed)


func button_pressed(b):
	if _controller.is_button_pressed(b) and !button_states.has(b):
		button_states.append(b)
		return true
	if not _controller.is_button_pressed(b) and button_states.has(b):
		button_states.erase(b)
	
	return false
	
	
# This method verifies the MovementProvider has a valid configuration.
func _get_configuration_warning():
	# Check the controller node
	var test_controller = get_parent()
	if !test_controller or !test_controller is ARVRController:
		return "Unable to find ARVR Controller node"

	# Call base class
	return ._get_configuration_warning()

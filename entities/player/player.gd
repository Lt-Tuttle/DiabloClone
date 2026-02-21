extends CharacterBody2D

@export var speed: float = 200.0

# Grab references to your nodes
@onready var animation_tree: AnimationTree = $AnimationTree
# Get the state machine playback object to switch between Idle and Walk
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready() -> void:
    # Ensure the animation tree is running
    animation_tree.active = true

func _physics_process(_delta: float) -> void:
    # 1. Get player input for movement (automatically clamped between -1 and 1)
    var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

    # 2. Calculate the direction towards the mouse
    # We subtract our position from the mouse position and normalize it
    # so the AnimationTree gets a clean direction vector (length of 1)
    var look_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()

    # 3. Determine Movement and Animation State
    if input_vector != Vector2.ZERO:
        # We are moving
        velocity = input_vector * speed
        # Tell the State Machine to play the Walk blend space (fixed from "Idle")
        state_machine.travel("Walk")
    else:
        # We are stopped
        velocity = Vector2.ZERO
        # Tell the State Machine to play the Idle blend space
        state_machine.travel("Idle")

    # 4. Update the Blend Positions
    # We update BOTH Idle and Walk spaces with the mouse's look_direction.
    # This ensures the player always faces the mouse, whether moving or standing still.
    animation_tree.set("parameters/Idle/blend_position", look_direction)
    animation_tree.set("parameters/Walk/blend_position", look_direction)

    # 5. Apply the physics movement
    move_and_slide()
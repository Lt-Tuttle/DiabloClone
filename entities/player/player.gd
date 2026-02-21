extends CharacterBody2D

@export var speed: float = 100.0

var facing_direction: Vector2 = Vector2.DOWN
@onready var target_position: Vector2 = global_position

# Grab references to your nodes
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var debug_label: Label = $DebugLabel
# Get the state machine playback object to switch between Idle and Walk
@onready var state_machine = animation_tree.get("parameters/playback")

func _ready() -> void:
    # Ensure the animation tree is running
    animation_tree.active = true

func _unhandled_input(event: InputEvent) -> void:
    # Check for left mouse click
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        target_position = get_global_mouse_position()

func _physics_process(_delta: float) -> void:
    var distance_to_target: float = global_position.distance_to(target_position)

    # 1. Determine Movement, Animation State, and Facing Direction
    # Only move if we are sufficiently far from the target
    if distance_to_target > 5.0:
        var move_direction: Vector2 = (target_position - global_position).normalized()

        # Snap the angle to the nearest 16-direction increment (22.5 degrees / PI/8)
        # This ensures the AnimationTree maps exactly to one of your 16 walk animations
        # without trying to blend them into "strange" in-between directions.
        var snapped_angle: float = snapped(move_direction.angle(), PI / 8.0)
        facing_direction = Vector2.RIGHT.rotated(snapped_angle)

        # We are moving
        velocity = move_direction * speed
        # Tell the State Machine to play the Walk blend space
        state_machine.travel("Walk")
    else:
        # We are stopped
        velocity = Vector2.ZERO
        # Tell the State Machine to play the Idle blend space
        state_machine.travel("Idle")

    debug_label.text = "Target: " + str(target_position) + "\n" + "Facing: " + str(facing_direction)
    # 2. Update the Blend Positions
    # We update BOTH Idle and Walk spaces with the facing_direction.
    # This ensures the player always faces their movement direction.
    animation_tree.set("parameters/Idle/blend_position", facing_direction)
    animation_tree.set("parameters/Walk/blend_position", facing_direction)

    # 3. Apply the physics movement
    move_and_slide()


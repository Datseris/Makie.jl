function calc_drag(buttons, drag, indrag, tracked_mousebutton)
    # only track if still the same button is pressed
    if length(buttons) == 1 && (!indrag[] || tracked_mousebutton[] == first(buttons))

        if !indrag[]
            tracked_mousebutton[] = first(buttons); indrag[] = true
            drag[] = Mouse.down # just started, so dragging is still false
            return drag[]
        else
            drag[] = Mouse.pressed
            return drag[]
        end
    end
    # already on notpressed, no need for update
    if drag[] != Mouse.notpressed
        drag[] = indrag[] ? Mouse.up : Mouse.notpressed
    end
    indrag[] = false
    return drag[]
end

function mousedrag(scene::Scene, native_window)
    indrag = RefValue(false)
    tracked_mousebutton = RefValue(Mouse.left)
    drag = RefValue(Mouse.notpressed)
    events = scene.events
    foreach(events.mouseposition, events.mousebuttons) do mp, buttons
        events.mousedrag[] = calc_drag(buttons, drag, indrag, tracked_mousebutton)
        return
    end
    return
end

function disconnect!(window::AbstractScreen, signal)
    disconnect!(to_native(window), signal)
end

function register_callbacks(scene::Scene, native_window)
    window_area(scene, native_window)
    window_open(scene, native_window)
    mouse_buttons(scene, native_window)
    mouse_position(scene, native_window)
    mousedrag(scene, native_window)
    scroll(scene, native_window)
    keyboard_buttons(scene, native_window)
    unicode_input(scene, native_window)
    dropped_files(scene, native_window)
    hasfocus(scene, native_window)
    entered_window(scene, native_window)
end
button_key{T}(x::Type{T}) = error("Must be a keyboard or mouse button. Found: $T")
button_key(x::Type{Keyboard.Button}) = :keyboardbuttons
button_key(x::Type{Mouse.Button}) = :mousebuttons
button_key{T}(x::Set{T}) = button_key(T)
button_key{T}(x::T) = button_key(T)

"""
returns true if `button` is pressed in scene[:mousebuttons or :keyboardbuttons]
You can use nothing, to indicate it should always return true
"""
function ispressed(scene::Scene, button::Union{Vector, Tuple})
    all(x-> ispressed(scene, x), button)
end

# TODO this is a bit shady, but maybe a nice api!
# So you can use void whenever you don't care what is pressed
ispressed(scene::Scene, ::Void) = true

function ispressed(scene::Scene, button)
    buttons = getfield(scene.events, button_key(button))[]
    if isa(button, Set)
        return buttons == button
    else
        return length(buttons) == 1 && first(buttons) == button
    end
end

local module = {}

--Animation has:
--animation_state
--animation_timer

function module.set_animation(c_data, animation)
    c_data.animation_state = animation
    c_data.animation_timer = animation.frames * animation.frame_time
end

function module.get_animation_frame(animation, anim_timer)
    return animation[math.ceil(anim_timer / animation.frame_time)]
end

function module.update_timer(animation, anim_timer)
    return anim_timer > 1
        and anim_timer - 1
        or animation.loop
            and animation.frames * animation.frame_time
            or 0
end
return module

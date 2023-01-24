local module = {}

--Animation has:
--animation_state
--animation_timer

function module.set_animation(c_data, animation, frame_time)
    c_data.animation_state = animation
    c_data.animation_timer = animation.frames*frame_time
end

function module.get_animation_frame(animation, anim_timer)
    return animation[math.ceil(anim_timer / (animation.frame_time or 4))]
end

return module

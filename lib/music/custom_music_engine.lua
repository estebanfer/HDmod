--[[
Custom Music Engine v1.0.0

This module provides functions to replace vanilla music with custom music.

The custom music will imitate the following vanilla music behaviors:
    Mutes itself to allow back layer music, shop music, and vendor anger music to play.
    Stops playing when vanilla music would stop playing, such as during the death screen or when changing worlds.
    Lowers in volume when paused or in a level transition.
    Lowers in pitch when the ghost is present.

Custom music limitations:
    Doesn't smoothly adjust volume and pitch like vanilla music.
    Can't apply a muffling effect, and instead imitates this effect by just lowering its volume.
    Can't imitate some of the dynamic behaviors of vanilla music, like tracks changing for player health and level feelings.
    Custom track timing precision is tied to the user's graphical frame rate. Timing may sound a bit wrong at low frame rates.

This module should be loaded as early as possible because it needs to capture the creation of the BGM master vanilla sound. There is no way to find a BGM master that already exists, so this module will not be functional until a new one is created.
]]

-- Naming convention: Variables named "sound" are CustomSound objects, and variables named "psound" are PlayingSound objects.

local module = {}

local CUSTOM_MUSIC_BASE_VOLUME = 0.6

local custom_music_settings
local custom_music_playing
local custom_music_intro_started
local custom_music_loop_next_index
local custom_music_loop_next_start_time
local custom_music_mute
local custom_music_volume
local custom_music_pitch
local custom_music_psounds = {} -- A few checks are simplified by never letting this be nil.
local custom_music_frame_callback_id

local bgm_master_psound
local bgm_master_prev_current_theme
local bgm_master_prev_current_shop_type
local bgm_master_create_callback_id

-- Initializes the variables that control the custom music. This should only be called if a BGM master is active, custom music is set, and that custom music is not already playing. This function just initializes the variables, after which the frame callback is responsible for creating sounds.
local function init_custom_music()
    custom_music_playing = true
    custom_music_intro_started = false
    custom_music_loop_next_index = 1
    custom_music_loop_next_start_time = get_ms() + custom_music_settings.loop_start_delay
    custom_music_mute = false
    custom_music_volume = 1.0
    custom_music_pitch = 1.0
end

-- Stops all playing custom music.
local function stop_custom_music()
    custom_music_playing = false
    for index, psound in pairs(custom_music_psounds) do
        psound:stop()
        custom_music_psounds[index] = nil
    end
end

-- Configures and starts playing a custom music sound.
local function play_custom_music_sound(sound, uid)
    local psound = sound:play(true, SOUND_TYPE.MUSIC)
    custom_music_psounds[uid] = psound
    psound:set_looping(SOUND_LOOP_MODE.OFF)
    psound:set_mute(custom_music_mute)
    psound:set_volume(CUSTOM_MUSIC_BASE_VOLUME * custom_music_volume)
    psound:set_pitch(custom_music_pitch)
    psound:set_pause(false)
end

-- Gets whether vanilla shop music would be currently playing. This does not check for vendor anger music, which takes priority over shop music.
local function is_shop_music_playing()
    return not test_flag(get_level_flags(), 18) -- Dark levels do not play shop music.
        -- This shop check isn't totally accurate. The vanilla shop check is based on the position of the leader player, not the camera focus. If the last living player dies, then the check is still based on the position of their body. It only falls back to using the camera focus if their body is destroyed. The camera focus is typically the leader, but mods could change it to be something else. I'm using this slightly inaccurate check instead because I haven't found a reliable way to determine who is the leader.
        and is_inside_active_shop_room(state.camera.focus_x, state.camera.focus_y, state.camera_layer)
        and is_inside_shop_zone(state.camera.focus_x, state.camera.focus_y, state.camera_layer)
end

-- Mutes or unmutes all playing custom music sounds.
local function set_mute_custom_music_psounds(mute)
    if custom_music_mute == mute then
        return
    end
    for _, psound in pairs(custom_music_psounds) do
        psound:set_mute(mute)
    end
    custom_music_mute = mute
end

-- Sets the volume of all playing custom music sounds.
local function set_volume_custom_music_psounds(volume)
    if custom_music_volume == volume then
        return
    end
    for _, psound in pairs(custom_music_psounds) do
        psound:set_volume(CUSTOM_MUSIC_BASE_VOLUME * volume)
    end
    custom_music_volume = volume
end

-- Sets the pitch of all playing custom music sounds.
local function set_pitch_custom_music_psounds(pitch)
    if custom_music_pitch == pitch then
        return
    end
    for _, psound in pairs(custom_music_psounds) do
        psound:set_pitch(pitch)
    end
    -- Changing the pitch changes the lengths of the sounds. Adjust the start time for the next loop sound. This shouldn't accumulate noticeable floating point errors unless an excessive number of pitch changes occur during a single loop.
    local current_time = get_ms()
    local ms_until_next_start_time = custom_music_loop_next_start_time - current_time
    custom_music_loop_next_start_time = current_time + (ms_until_next_start_time * custom_music_pitch / pitch)
    custom_music_pitch = pitch
end

-- Discards handles for custom music sounds that have finished playing.
local function clean_custom_music_psounds()
    for index, psound in pairs(custom_music_psounds) do
        if not psound:is_playing() then
            custom_music_psounds[index] = nil
        end
    end
end

-- Checks the current game state and modifies all playing custom music sounds as needed. This should only be called if custom music is playing.
local function modify_custom_music_psounds()
    -- Check whether the custom music needs be muted.
    local mute = false
    if state.camera_layer ~= LAYER.FRONT then
        -- Mute while not in the front layer.
        mute = true
    elseif bgm_master_psound and bgm_master_psound:get_parameter(VANILLA_SOUND_PARAM.ANGER_STATE) == 1 then
        -- Mute during vendor anger music.
        mute = true
    elseif not custom_music_settings.play_over_shop_music and is_shop_music_playing() then
        -- Mute during shop music.
        mute = true
    end
    set_mute_custom_music_psounds(mute)

    -- Check whether the custom music needs its volume changed.
    local volume = 1.0
    if state.screen == ON.TRANSITION and state.theme ~= THEME.COSMIC_OCEAN then
        -- Reduce volume while in a non-CO level transition. There is a muffling effect for vanilla music, but this change sounds reasonably close.
        volume = 0.2
    elseif test_flag(state.pause, 1) then
        -- Reduce volume while paused. There is a muffling effect for vanilla music, but this change sounds reasonably close.
        volume = 0.4
    end
    set_volume_custom_music_psounds(volume)

    -- Check whether the custom music needs its pitch changed.
    local pitch = 1.0
    if bgm_master_psound:get_parameter(VANILLA_SOUND_PARAM.GHOST) > 0 then
        -- Lower pitch while the ghost is present. I'm not sure if this is the exact effect applied to the vanilla music, but it sounds reasonably close. This number was obtained by recording ghost music from the game and comparing it with the raw music files. I don't know why it seems so arbitrary.
        pitch = 0.90101
    end
    set_pitch_custom_music_psounds(pitch)
end

local BGM_MASTER_SILENT_CURRENT_THEME = 17
local BGM_MASTER_SILENT_CURRENT_SHOP_TYPE = 11
-- Mutes or unmutes the BGM master. PlayingSound:set_mute() irreversibly mutes the BGM master, and PlayingSound:set_volume() does not seem to have any effect. This function instead "mutes" the BGM master by changing its parameters to play tracks that don't exist, and "unmutes" it by restoring the original parameters. The chosen silent tracks are assumed to never be used by the game engine.
local function set_mute_bgm_master_psound(mute)
    if not bgm_master_psound or not bgm_master_psound:is_playing() then
        return
    end

    local current_theme = bgm_master_psound:get_parameter(VANILLA_SOUND_PARAM.CURRENT_THEME)
    local current_shop_type = bgm_master_psound:get_parameter(VANILLA_SOUND_PARAM.CURRENT_SHOP_TYPE)
    if mute then
        if current_theme ~= BGM_MASTER_SILENT_CURRENT_THEME then
            bgm_master_prev_current_theme = current_theme
            bgm_master_psound:set_parameter(VANILLA_SOUND_PARAM.CURRENT_THEME, BGM_MASTER_SILENT_CURRENT_THEME)
        end
        if current_shop_type ~= BGM_MASTER_SILENT_CURRENT_SHOP_TYPE and custom_music_settings and custom_music_settings.play_over_shop_music then
            bgm_master_prev_current_shop_type = current_shop_type
            bgm_master_psound:set_parameter(VANILLA_SOUND_PARAM.CURRENT_SHOP_TYPE, BGM_MASTER_SILENT_CURRENT_SHOP_TYPE)
        end
    else
        if bgm_master_prev_current_theme and bgm_master_prev_current_theme ~= current_theme then
            bgm_master_psound:set_parameter(VANILLA_SOUND_PARAM.CURRENT_THEME, bgm_master_prev_current_theme)
            bgm_master_prev_current_theme = nil
        end
        if bgm_master_prev_current_shop_type and bgm_master_prev_current_shop_type ~= current_shop_type then
            bgm_master_psound:set_parameter(VANILLA_SOUND_PARAM.CURRENT_SHOP_TYPE, bgm_master_prev_current_shop_type)
            bgm_master_prev_current_shop_type = nil
        end
    end
end

-- Performs custom music checks and modifications that need to occur on every frame. This function should only be called if custom music has been set.
local function do_custom_music_frame()
    if not custom_music_frame_callback_id then
        -- Due to an API issue, this callback might execute one more time after it's cleared.
        return
    end

    if custom_music_playing then
        -- Custom music is playing. Check whether it needs to be stopped.
        if not bgm_master_psound or not bgm_master_psound:is_playing() then
            -- Custom music should only play when vanilla music would be playing.
            stop_custom_music()
            return
        end
    else
        -- Custom music is not playing. Check whether it can be started now.
        if bgm_master_psound and bgm_master_psound:is_playing() then
            init_custom_music()
        else
            return
        end
    end

    -- The BGM master will occasionally unmute itself when the game engine changes its parameters. Make sure it stays muted.
    set_mute_bgm_master_psound(true)

    if not custom_music_intro_started then
        -- Play the intro sound if one is configured.
        if custom_music_settings.intro_sound then
            play_custom_music_sound(custom_music_settings.intro_sound, -1)
        end
        custom_music_intro_started = true
    end

    if custom_music_settings.loop_sounds and #custom_music_settings.loop_sounds > 0 then
        -- The default looping feature for PlayingSound objects uses the track length, but most sounds have a silent period at the end of the track. This code makes them loop based on configured timings instead, and supports cycling through different loop sounds. It keeps track of when the custom music was started and plays one instance of a loop sound whenever the correct amount of time has passed. Previous sounds are not stopped when a new one plays because they may be designed to blend into the next sound.
        if get_ms() >= custom_music_loop_next_start_time then
            -- This is a good place to periodically clean up finished PlayingSound objects.
            clean_custom_music_psounds()
            -- Play one instance of the next loop sound.
            local loop_sound_data = custom_music_settings.loop_sounds[custom_music_loop_next_index]
            play_custom_music_sound(loop_sound_data.sound, custom_music_loop_next_start_time)
            -- Determine the next loop sound and calculate when it should play.
            custom_music_loop_next_index = (custom_music_loop_next_index % #custom_music_settings.loop_sounds) + 1
            custom_music_loop_next_start_time = custom_music_loop_next_start_time + (loop_sound_data.length / custom_music_pitch)
        end
    end

    -- Apply modifications to the custom music based on the current game state.
    modify_custom_music_psounds()
end

local function create_custom_music_frame_callback()
    if not custom_music_frame_callback_id then
        -- This function needs to run as often as possible, and this was the most reliable callback I could find for it. Game frame and global interval callbacks don't run under some circumstances, which causes noticeable delays in the custom music behavior.
        custom_music_frame_callback_id = set_callback(do_custom_music_frame, ON.GUIFRAME)
    end
end

local function clear_custom_music_frame_callback()
    if custom_music_frame_callback_id then
        clear_callback(custom_music_frame_callback_id)
        custom_music_frame_callback_id = nil
    end
end

-- Creates a callback to keep track of the creation of BGM master vanilla sounds. The BGM master is the vanilla sound responsible for all of the music in standard levels. Some events can create multiple BGM masters, but the latest one created is always the one kept by the game engine. The callbacks for stopping and destroying vanilla sounds are unreliable because they seem to provide object pointers that were never provided by the creation callback. Instead, the PlayingSound:is_playing() function can be used to determine whether a BGM master is still active.
local function create_bgm_master_callback()
    bgm_master_create_callback_id = set_vanilla_sound_callback(VANILLA_SOUND.BGM_BGM_MASTER, VANILLA_SOUND_CALLBACK_TYPE.CREATED, function(psound)
        bgm_master_psound = psound
        bgm_master_prev_current_theme = nil
        bgm_master_prev_current_shop_type = nil
        if custom_music_settings then
            -- Immediately mute the new BGM master if custom music is set.
            set_mute_bgm_master_psound(true)
        end
    end)
end

-- Creates a callback to clear the custom music when the script is disabled.
local function create_disable_callback()
    set_callback(function()
        module.clear_custom_music()
    end, ON.SCRIPT_DISABLE)
end

--[[
Sets the custom music to play instead of the vanilla music. If custom music is already playing, then it will be stopped and replaced with the new custom music settings.
settings:
    A table describing the custom music to play. Nil will clear the custom music and restore the vanilla music. An empty table will just mute the vanilla music. The settings are not validated and bad values can cause problems later, so be sure to follow these specifications.
    {
         -- Sound to play once when the custom music starts. Leave nil for no intro sound.
        intro_sound = PlayingSound,
        -- Milliseconds to wait before starting the loop. The intro sound does not stop when this time elapses. Defaults to 0.
        loop_start_delay = Number,
         -- Zero or more sounds to play in a loop. The sounds are played one at a time in the given order.
        loop_sounds = {
            {
                -- Sound to play for a loop iteration.
                sound = PlayingSound,
                -- Milliseconds to wait after starting this sound before starting the next one. This sound does not stop when this time elapses. This value is required and must be a positive number.
                length = Number
            },
            ...
        },
        -- Whether to keep playing custom music in a shop instead of muting it and allowing vanilla shop music to play. Defaults to false.
        play_over_shop_music = Boolean
    }
]]
function module.set_custom_music(settings)
    if not custom_music_settings and not settings then
        -- There is already no custom music set.
        return
    end

    -- Stop any custom music that is currently playing.
    stop_custom_music()
    -- Unmute the BGM master because the new custom music might have different muting behavior. It will be re-muted immediately if needed.
    set_mute_bgm_master_psound(false)

    if settings then
        -- Custom music is being set.
        custom_music_settings = {
            intro_sound = settings.intro_sound,
            loop_start_delay = settings.loop_start_delay or 0,
            play_over_shop_music = settings.play_over_shop_music or false
        }
        if settings.loop_sounds and #settings.loop_sounds > 0 then
            custom_music_settings.loop_sounds = {}
            for _, loop_sound_data in ipairs(settings.loop_sounds) do
                table.insert(custom_music_settings.loop_sounds, {
                    sound = loop_sound_data.sound,
                    length = loop_sound_data.length
                })
            end
        end
        -- Mute the vanilla music and start the frame callback. The frame callback will mute the vanilla music anyways, but muting it here avoids a stutter that can happen while it's briefly unmuted.
        set_mute_bgm_master_psound(true)
        create_custom_music_frame_callback()
    else
        -- Custom music is being cleared. Stop the frame callback.
        custom_music_settings = nil
        clear_custom_music_frame_callback()
    end
end

-- Clears the custom music and restores the vanilla music.
function module.clear_custom_music()
    module.set_custom_music(nil)
end

create_bgm_master_callback()
create_disable_callback()

return module

--[[- Flags and functions for defining the current state of a firearm.

@module RFF.Firearm.State
@author Fenris_Wolf
@release 1.0
@copyright 2018

]]

local State = {}

local Bit = require(ENV_RFF_PATH .. "interface/bit32")

--- integer 8, Singleshot or Semi-auto mode
State.SINGLESHOT = 8
-- full-atuo mode.
State.FULLAUTO = 16
-- fire 2 shot bursts 
State.BURST2 = 32 
-- fire 3 shot bursts
State.BURST3 = 64
-- safety engaged
State.SAFETY = 128
-- slide/bolt is open
State.OPEN = 256
-- gun is currently cocked
State.COCKED = 512
-- user specifically requested gun should be open. To prevent normal reloading from auto racking.
State.FORCEOPEN = 1024 

State.isFeedMode = function(firearm_data, feed_mode)
    local value = firearm_data.feed_mode or firearm_data.feed_system
    if not value then return end
    return Bit.band(value, feed_mode) ~= 0
end
State.isAutomatic = function(firearm_data)
    return State.isFeedMode(firearm_data, Flags.AUTO)
end
State.isPump = function(firearm_data)
    return State.isFeedMode(firearm_data, Flags.PUMP)
end
State.isLever = function(firearm_data)
    return State.isFeedMode(firearm_data, Flags.LEVER)
end
State.isRotary = function(firearm_data)
    return State.isFeedMode(firearm_data, Flags.ROTARY)
end
State.isBreak = function(firearm_data)
    return State.isFeedMode(firearm_data, Flags.BREAK)
end

State.isState = function(firearm_data, state)
    if not firearm_data.state then return end
    return Bit.band(firearm_data.state, state) ~= 0
end
State.isForceOpen = function(firearm_data)
    return State.isState(firearm_data, State.FORCEOPEN)
end

State.isFullAuto = function(firearm_data)
    return State.isState(firearm_data, State.FULLAUTO)
end

State.isSingle = function(firearm_data)
    return State.isState(firearm_data, State.SINGLESHOT)
end

State.is2ShotBurst = function(firearm_data)
    return State.isState(firearm_data, State.BURST2)
end

State.is3ShotBurst = function(firearm_data)
    return State.isState(firearm_data, State.BURST3)
end

State.isSafe = function(firearm_data)
    return State.isState(firearm_data, State.SAFETY)
end

State.isCocked = function(firearm_data)
    return State.isState(firearm_data, State.COCKED)
end

State.isOpen = function(firearm_data)
    return State.isState(firearm_data, State.OPEN)
end

State.setState = function(firearm_data, state, enabled)
    if enabled then
        firearm_data.state = not State.isState(firearm_data, state) and firearm_data.state + state or firearm_data.state
    else
        firearm_data.state = Bit.bor(state, firearm_data.state)
    end
end

State.setOpen = function(firearm_data, enabled)
    State.setState(firearm_data, State.OPEN, enabled)
end

State.setCocked = function(firearm_data, enabled)
    State.setState(firearm_data, State.COCKED, enabled)
end

State.setForceOpen = function(firearm_data, enabled)
    State.setState(firearm_data, State.FORCEOPEN, enabled)
end

return State

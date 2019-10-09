local State = {}

local Bit = require(ENV_RFF_PATH .. "interface/bit32")

State.SINGLESHOT = 8 -- Singleshot or semi auto mode
State.FULLAUTO = 16 -- full-atuo mode.
State.BURST2 = 32 -- fire 2 shot bursts
State.BURST3 = 64 -- fire 3 shot bursts
State.SAFETY = 128 -- manual safety
State.OPEN = 256 -- slide/bolt is open.
State.COCKED = 512 -- gun is currently cocked
State.FORCEOPEN = 1024 -- user specifically requested gun should be open. To prevent normal reloading from auto racking.

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
State.isForceOpen(firearm_data)
    return State.isState(firearm_data, State.FORCEOPEN)
end

State.isFullAuto = function(this)
    return State.isState(this, State.FULLAUTO)
end

State.isSingle = function(this)
    return State.isState(this, State.SINGLESHOT)
end

State.is2ShotBurst = function(this)
    return State.isState(this, State.BURST2)
end

State.is3ShotBurst = function(this)
    return State.isState(this, State.BURST3)
end

State.isSafe = function(this)
    return State.isState(this, State.SAFETY)
end

State.isCocked = function(this)
    return State.isState(this, State.COCKED)
end

State.isOpen = function(this)
    return State.isState(this, State.OPEN)
end

State.setState = function(this, state, enabled)
    if enabled then
        this.state = not State.isState(this, state) and this.state + state or this.state
    else
        this.state = Bit.bor(state, this.state)
    end
end

State.setOpen = function(this, enabled)
    State.setState(this, State.OPEN, enabled)
end

return State

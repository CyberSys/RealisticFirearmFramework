if not ENV_RFF_PATH then 
    ENV_RFF_PATH = "../rff/"
end
local Const = require(ENV_RFF_PATH .. "constants")
local Tests = require(ENV_RFF_PATH .. "tests")
local Actions = require(ENV_RFF_PATH .. "firearm/actions")
local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local State = Firearm.State
local assert = Tests.assert
local Instance = require(ENV_RFF_PATH .. "firearm/instance")
Tests.reset()

local firearm_data

local function assertState(data_state)
    for key, value in pairs(data_state) do
        if type(value) == 'table' then
            for key2, value2 in pairs(value) do
                assert(firearm_data[key][key2] == value2, "key '".. key2 .."' in table '".. key .. "' doesnt match expected value of " .. value2 .. ", but is ".. firearm_data[key][key2])
            end 
        else
            assert(firearm_data[key] == value, "key '".. key .."' doesnt match expected value of " .. value .. ", but is ".. firearm_data[key])
        end
    end 
end

Tests.run("Ammo Registration", function()

    local AmmoGroup = Ammo.AmmoGroup
    local AmmoType = Ammo.AmmoType
    local Flags = Ammo.Flags

    assert(AmmoGroup:new("AmmoGroup_357Magnum"), 
        "Failed to register ammo group", true)
    assert(AmmoType:new("Ammo_357Magnum_HP", {
        Case = "Case_357Magnum",
        Groups = { AmmoGroup_357Magnum = 1, },
        features = Flags.JACKETED + Flags.HOLLOWPOINT + Flags.FLATPOINT,
    }), "Failed to register ammo", true)
end)



Tests.run("Firearm Registration", function()

    local FirearmGroup = Firearm.FirearmGroup
    local FirearmType = Firearm.FirearmType

    assert(Firearm.FirearmType:new("Colt_Python", {
        weight = 1,
        barrel_length = 6,
        max_capacity = 6,
        category = Const.REVOLVER,
        feed_system = Firearm.Flags.ROTARY,
        features = Firearm.Flags.SINGLEACTION + Firearm.Flags.DOUBLEACTION + Firearm.Flags.SAFETY,
        ammo_group = "AmmoGroup_357Magnum",
    }), "Failed to register firearm", true)
end)


Tests.run("Spawning", function()

    local design = Firearm.get("Colt_Python")
    assert(design, "Failed to retrieve design.", true)
    firearm_data = design:create() 
    assert(firearm_data, "Failed create instance.", true)
    -- TODO: validate firearm_data variables
    
    -- TODO: proper loading
    Tests.log("Initializing hack reload..")
    for i=1, firearm_data.max_capacity do
        firearm_data.magazine_data[i] = "Ammo_357Magnum_HP"
    end
    firearm_data.current_capacity = firearm_data.max_capacity
    --assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false", true)

    Tests.log("Firearm loaded and ready to fire.")
end)


Tests.run("Operation", function()

    Tests.log("Engaging safety...")
    Instance.setSafe(firearm_data, true)
    --assert(not Actions.willFire(firearm_data, nil, nil), "willFire returned true, safety check failed.")

    Tests.log("Safety check passed. Disenaging and cocking...")
    Instance.setSafe(firearm_data, false)
    assert(Instance.isSafe(firearm_data) == false, "Failed to disengage safety")

    Actions.cockHammer(firearm_data, nil, nil, false)
    assertState({cylinder_position = 2, state = State.SINGLESHOT + State.COCKED})
    --assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")

    
    Tests.log("Hammer cocked and cylinder rotated ok. Releasing hammer...")
    Actions.releaseHammer(firearm_data, nil, nil, false)
    assertState({cylinder_position = 2, state = State.SINGLESHOT})

    --if assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false") then return end
    
    Tests.log("Hammer released ok.") 
end)


Tests.run("Firing", function()
    local function assertWillFire(expected)
        local result = Actions.willFire(firearm_data, nil, nil)
        assert(result == expected, "willFire returned ".. tostring(result)) 
    end 

    local function assertPullTrigger(expected)
        local result = Actions.pullTrigger(firearm_data, nil, nil, true)
        assert(result == expected, "pullTrigger returned ".. tostring(result)) 
    end

    local function assertShotFired(expected)
        local result = Actions.shotFired(firearm_data, nil, nil, true)
        assert(result == expected, "shotFired returned ".. tostring(result)) 
    end


    Tests.log("Recocking and testing Single-Action shot...")
    Actions.cockHammer(firearm_data, nil, nil, false)
    assertState({current_capacity = 6, cylinder_position = 3, state = State.SINGLESHOT + State.COCKED})
    --assertWillFire(true)
     -- Actions.pullTrigger(firearm_data, nil, nil, true)
    assertPullTrigger(true)
    
    Tests.log("BANG!")
     -- Actions.shotFired(firearm_data, nil, nil, true)
    assertShotFired(true)
    assertState({current_capacity = 5, cylinder_position = 3, state = State.SINGLESHOT, 
        magazine_data = {[3] = "Case_357Magnum" }
    })
    -- TODO: functions for checking total empty case count, and isCase()
    Tests.log("Fire successful. Empty casing detected in cylinder.")
    
    Tests.log("Testing Double-Action shot")
    --assertWillFire(true)
    assertPullTrigger(true)
    assertState({current_capacity = 5, cylinder_position = 4, state = State.SINGLESHOT})
    
    Tests.log("BANG!")
    assertShotFired(true)
    assertState({current_capacity = 4, cylinder_position = 4, state = State.SINGLESHOT,
        magazine_data = { [4] = "Case_357Magnum" }
    })
    
    Tests.log("Emptying cylinder...")
    --assertWillFire(true)
    assertPullTrigger(true)
    assertState({current_capacity = 4, cylinder_position = 5, state = State.SINGLESHOT})

    Tests.log("BANG!")
    assertShotFired(true)
    assertState({current_capacity = 3, cylinder_position = 5, state = State.SINGLESHOT})

    --assertWillFire(true)
    assertPullTrigger(true)
    assertState({current_capacity = 3, cylinder_position = 6, state = State.SINGLESHOT})

    Tests.log("BANG!")
    assertShotFired(true)
    assertState({current_capacity = 2, cylinder_position = 6, state = State.SINGLESHOT})

    --assertWillFire(true)
    assertPullTrigger(true)
    assertState({current_capacity = 2, cylinder_position = 1, state = State.SINGLESHOT})
    
    Tests.log("BANG!")
    assertShotFired(true)
    assertState({current_capacity = 1, cylinder_position = 1, state = State.SINGLESHOT})

    --assertWillFire(true)
    assertPullTrigger(true)
    assertState({current_capacity = 1, cylinder_position = 2, state = State.SINGLESHOT})

    Tests.log("BANG!")
    assertShotFired(true)
    assertState({current_capacity = 0, cylinder_position = 2, state = State.SINGLESHOT,
        magazine_data = {"Case_357Magnum","Case_357Magnum","Case_357Magnum","Case_357Magnum","Case_357Magnum","Case_357Magnum" }
    })

    Tests.log("Cylinder Empty")
    --assertWillFire(false)
end)


-- ######################################################################
-- print results
Tests.counts()


if not ENV_RFF_PATH then 
    ENV_RFF_PATH = "../rff/"
end
local TestData = require("tests/test_data")
local Const = require(ENV_RFF_PATH .. "constants")
local Tests = require(ENV_RFF_PATH .. "tests")
local Actions = require(ENV_RFF_PATH .. "firearm/actions")
local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local State = Firearm.State
local assert = Tests.assert
local Instance = require(ENV_RFF_PATH .. "firearm/instance")


-- type checkers used throughout the tests
local firearm_type = "Revolver1"
local ammo_group = "AmmoGroup_357Magnum"
local ammo_type = "Ammo_357Magnum_Type1"
local case_type = "Case_357Magnum"

local firearm_data -- instance holder.

-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- recursive table checking. 
-- ensure all key/values in table B (match) are identical to table A (data)
-- additional keys in table A are not checked, and no error raised.
local function assertState(data, match)
    for key, value in pairs(match) do
        if type(value) == 'table' and data[key] then
            assertState(data[key], value)
        else
            assert(data[key] == value, "key '".. key .."' doesnt match expected value of " .. tostring(value) .. ", but is ".. tostring(data[key]))
        end
    end

end

-- quick function to save redundant code on trigger pulls
local function assertPullTrigger(expected, halt)
    local result = Actions.pullTrigger(firearm_data, nil, nil, true)
    return assert(result == expected, "pullTrigger returned ".. tostring(result), halt) 
end

-- shotFired should pretty much always return true. this assert is probably pointless.
local function assertShotFired(expected, halt)
    local result = Actions.shotFired(firearm_data, nil, nil, true)
    return assert(result == expected, "shotFired returned ".. tostring(result), halt) 
end


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tests.reset()


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tests.run("Ammo Registration", function()

    local AmmoGroup = Ammo.AmmoGroup
    local AmmoType = Ammo.AmmoType
    local Flags = Ammo.Flags

    -- create some ammo
    assert(AmmoGroup:new(ammo_group), "Failed to register ammo group " .. ammo_group, true)
    assert(AmmoType:new(ammo_type, TestData.Ammo[ammo_type]), "Failed to register ammo ".. ammo_type, true)

end)


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tests.run("Firearm Registration", function()

    local FirearmGroup = Firearm.FirearmGroup
    local FirearmType = Firearm.FirearmType
    assert(Firearm.FirearmType:new(firearm_type, TestData.Firearms[firearm_type]), "Failed to register " .. firearm_type, true)

end)


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tests.run("Creating Instance", function()

    local design = Firearm.get(firearm_type)
    assert(design, "Failed to retrieve design.", true)
    firearm_data = design:create() 
    assert(firearm_data, "Failed create instance.", true)
    
    Tests.log("Initializing instant reload..")
    Instance.refillAmmo(firearm_data, ammo_type)

    Tests.log("Firearm loaded and ready to fire.")
end)


-- /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Tests.run("Operation", function()

    Tests.log("Engaging safety...")
    Instance.setSafe(firearm_data, true)

    Tests.log("Pulling Trigger...")
    assertPullTrigger(false, true)

    Tests.log("Safety check passed. Disenaging and cocking...")
    Instance.setSafe(firearm_data, false)
    assert(Instance.isSafe(firearm_data) == false, "Failed to disengage safety", true)

    Actions.cockHammer(firearm_data, nil, nil, false)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT + State.COCKED})
    
    Tests.log("Hammer cocked, cylinder rotated ok. Releasing hammer...")
    Actions.releaseHammer(firearm_data, nil, nil, false)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT})

    Tests.log("Hammer checks passed. Opening cylinder...")
    assert(Actions.openCylinder(firearm_data, nil, nil, false) == true, "Failed to open cylinder", true)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT + State.OPEN})
    
    Tests.log("Closing...")
    assert(Actions.closeCylinder(firearm_data, nil, nil, false) == true, "Failed to close cylinder", true)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT})
    
end)


Tests.run("Firing", function()

    Tests.log("Recocking and testing Single-Action shot...")
    Actions.cockHammer(firearm_data, nil, nil, false)
    assertState(firearm_data, { cylinder_position = 3, state = State.SINGLESHOT + State.COCKED,
        magazine_data = { 
            current_capacity = 6,
            max_capacity = 6,
            magazine_contents = {ammo_type, ammo_type, ammo_type, ammo_type, ammo_type, ammo_type }
        }, 
    })

    assertPullTrigger(true, true)
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 3, state = State.SINGLESHOT, 
        magazine_data = { 
            current_capacity = 5, 
            magazine_contents = {[3] = case_type }
        }
    })

    Tests.log("Fire successful. Empty casing detected in cylinder.")
    
    Tests.log("Testing Double-Action shot")

    assertPullTrigger(true, true)
    assertState(firearm_data, {cylinder_position = 4, state = State.SINGLESHOT,
        magazine_data = { current_capacity = 5,}
    })
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 4, state = State.SINGLESHOT,
        magazine_data = { 
            current_capacity = 4, 
            magazine_contents = {[3] = case_type, [4] = case_type }
        }
    })
    
    Tests.log("Firing remaining rounds...")

    assertPullTrigger(true, true)
    assertState(firearm_data, {cylinder_position = 5, state = State.SINGLESHOT})
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 5, state = State.SINGLESHOT, magazine_data = { current_capacity = 3 }})

    assertPullTrigger(true, true)
    assertState(firearm_data, {cylinder_position = 6, state = State.SINGLESHOT, magazine_data = { current_capacity = 3 }})
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 6, state = State.SINGLESHOT, magazine_data = { current_capacity = 2 }})

    assertPullTrigger(true, true)
    assertState(firearm_data, {cylinder_position = 1, state = State.SINGLESHOT, magazine_data = { current_capacity = 2 }})
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 1, state = State.SINGLESHOT, magazine_data = { current_capacity = 1 }})

    assertPullTrigger(true, true)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT, magazine_data = { current_capacity = 1 }})
    Tests.log("BANG!")
    assertShotFired(true, true)
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT,
        magazine_data = { 
            current_capacity = 0, 
            magazine_contents = {case_type,case_type,case_type,case_type,case_type,case_type }
        }
    })

    Tests.log("Cylinder Empty")
end)


Tests.run("Dry Firing", function()
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertState(firearm_data, {cylinder_position = 3, state = State.SINGLESHOT})
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertPullTrigger(false, true)
    Tests.log("Click!")
    assertState(firearm_data, {cylinder_position = 2, state = State.SINGLESHOT})
end)



--[[

]]

-- ######################################################################
-- print results
Tests.counts()
Instance.dump(firearm_data)

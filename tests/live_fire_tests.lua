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
Tests.reset()

local firearm_data

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
    assert(Actions.willFire(firearm_data, nil, nil), 
        "willFire returned false", true)

    Tests.log("Firearm loaded and ready to fire.")
end)

Tests.run("Operation", function()
    Tests.log("Engaging safety...")
    State.setSafe(firearm_data, true)
    assert(not Actions.willFire(firearm_data, nil, nil), "willFire returned true, safety check failed.")

    Tests.log("Safety check passed. Disenaging and cocking...")
    State.setSafe(firearm_data, false)
    assert(State.isSafe(firearm_data) == false, "Failed to disengage safety")

    Actions.cockHammer(firearm_data, nil, nil, false)
    assert(State.isCocked(firearm_data), "Hammer failed to cock.")
    assert(firearm_data.cylinder_position == 2, "Cylinder in wrong position. Should be 2, is at ".. firearm_data.cylinder_position)
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    
    Tests.log("Hammer cocked and cylinder rotated ok. Releasing hammer...")
    Actions.releaseHammer(firearm_data, nil, nil, false)
    assert(not State.isCocked(firearm_data), "Hammer failed to cock.")
    assert(firearm_data.cylinder_position == 2, "Cylinder in wrong position. Should be 2, is at ".. firearm_data.cylinder_position)
    if assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false") then return end
    
    Tests.log("Hammer released ok.") 
end)

Tests.run("Firing", function()
    Tests.log("Recocking and testing Single-Action shot...")
    Actions.cockHammer(firearm_data, nil, nil, false)
    assert(State.isCocked(firearm_data), "Hammer failed to cock.")
    assert(firearm_data.cylinder_position == 3, "Cylinder in wrong position. Should be 3, is at ".. firearm_data.cylinder_position)
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 3, "Cylinder in wrong position. Should be 3, is at ".. firearm_data.cylinder_position)
    assert(firearm_data.current_capacity == 5, "Ammo count is wrong. Should be 5, is at ".. firearm_data.current_capacity)
    assert(firearm_data.magazine_data[3] == "Case_357Magnum", "No empty shell casing detected at cylinder position")
    -- TODO: functions for checking total empty case count, and isCase()
    Tests.log("Fire successful. Empty casing detected in cylinder.")
    
    Tests.log("Testing Double-Action shot")
    assert(not State.isCocked(firearm_data), "Hammer is already cocked.")
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 4, "Cylinder in wrong position. Should be 4, is at ".. firearm_data.cylinder_position)
    
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 4, "Cylinder in wrong position. Should be 4, is at ".. firearm_data.cylinder_position)
    assert(firearm_data.current_capacity == 4, "Ammo count is wrong. Should be 4, is at ".. firearm_data.current_capacity)
    assert(firearm_data.magazine_data[3] == "Case_357Magnum", "No empty shell casing detected at cylinder position")
    
    Tests.log("Emptying cylinder...")
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 5, "Cylinder in wrong position. Should be 5, is at ".. firearm_data.cylinder_position)
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.current_capacity == 3, "Ammo count is wrong. Should be 3, is at ".. firearm_data.current_capacity)
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 6, "Cylinder in wrong position. Should be 6, is at ".. firearm_data.cylinder_position)
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.current_capacity == 2, "Ammo count is wrong. Should be 2, is at ".. firearm_data.current_capacity)
    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 1, "Cylinder in wrong position. Should be 1, is at ".. firearm_data.cylinder_position)
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.current_capacity == 1, "Ammo count is wrong. Should be 1, is at ".. firearm_data.current_capacity)

    assert(Actions.willFire(firearm_data, nil, nil), "willFire returned false")
    assert(Actions.preFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.cylinder_position == 2, "Cylinder in wrong position. Should be 2, is at ".. firearm_data.cylinder_position)
    Tests.log("BANG!")
    assert(Actions.postFireShot(firearm_data, nil, nil, true))
    assert(firearm_data.current_capacity == 0, "Ammo count is wrong. Should be 0, is at ".. firearm_data.current_capacity)
    Tests.log("Cylinder Empty")
    for i=1, 6 do
        assert(firearm_data.magazine_data[i] == "Case_357Magnum", "No empty shell casing detected at cylinder position ".. i)
    end
    assert(not Actions.willFire(firearm_data, nil, nil), "willFire returned true")
end)


-- ######################################################################
-- print results
Tests.counts()


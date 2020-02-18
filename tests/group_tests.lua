if not ENV_RFF_PATH then 
    ENV_RFF_PATH = "../rff/"
end
local Tests = require(ENV_RFF_PATH .. "tests")
local Actions = require(ENV_RFF_PATH .. "firearm/actions")
Tests.reset()

local TestGroup = setmetatable({}, {
    __index = require(ENV_RFF_PATH .. "item_group")
})
local TestType =  setmetatable({}, {
    __index = require(ENV_RFF_PATH .. "item_type")
})
local GroupTable = {}
local TypeTable = {}
TestGroup._GroupTable = GroupTable
TestGroup._ItemTable = TypeTable
TestType._GroupTable = GroupTable
TestType._ItemTable = TypeTable



Tests.run("Group Creation", function()
    TestGroup:new("Group_Top")
    TestGroup:new("Group_Mid_A", { groups = {Group_Top = 5 }})
    TestGroup:new("Group_Mid_B", { groups = {Group_Top = 3 }})
    TestGroup:new("Group_Mid_C", { groups = {Group_Top = 1 }})
    TestGroup:new("Group_Mid_D", { groups = {Group_Top = 2 }})

    TestGroup:new("Group_Bottom_A1", { groups = {Group_Mid_A = 3 }})
    TestGroup:new("Group_Bottom_A2", { groups = {Group_Mid_A = 3 }})

    TestGroup:new("Group_Bottom_B1", { groups = {Group_Mid_B = 1 }})
    TestGroup:new("Group_Bottom_B2", { groups = {Group_Mid_B = 0 }})

    TestGroup:new("Group_Bottom_C1", { groups = {Group_Mid_C = 1 }})

    TestGroup:new("Group_Bottom_BC1", { groups = {Group_Mid_B = 1, Group_Mid_C = 1 }})

    -- TODO: test bad group name, bad weight values, malformed tables etc
end)

-- Group size checking
Tests.run("Group Size Checking",function()
    Tests.assert(GroupTable.Group_Top:len() == 4, "Length Mismatch")
    Tests.assert(GroupTable.Group_Mid_A:len() == 2, "Length Mismatch")
    Tests.assert(GroupTable.Group_Mid_B:len() == 3, "Length Mismatch")
    Tests.assert(GroupTable.Group_Mid_C:len() == 2, "Length Mismatch")
    Tests.assert(GroupTable.Group_Mid_D:len() == 0, "Length Mismatch")
    -- TODO: test sizes after insertion and removal
end)
-- TODO: run tests on all ItemGroup methods, fuzz data.
-- repeat for ItemType class
Tests.run("Item Creation Checking", function()
    TestType:new("Item1", {groups = { Group_Mid_A = 1} })
    
    --Tests.assert(TypeTable.Item1:isGroupMember("Group_Mid_A"), "Not a member?")
end)

-- ######################################################################
-- print results
Tests.counts()

if not ENV_RFF_PATH then 
    ENV_RFF_PATH = "../rff/"
end
local Tests = require(ENV_RFF_PATH .. "tests")
Tests.reset()

local TestGroup = {}
local ItemGroup = require(ENV_RFF_PATH .. "item_group")
local GroupTable = {}

setmetatable(TestGroup, { __index = ItemGroup })
TestGroup._GroupTable = GroupTable
TestGroup._ItemTable = {}

Tests.run("Group Creation", function()
    TestGroup:new("Group_Top")
    TestGroup:new("Group_Mid_A", { Groups = {Group_Top = 5 }})
    TestGroup:new("Group_Mid_B", { Groups = {Group_Top = 3 }})
    TestGroup:new("Group_Mid_C", { Groups = {Group_Top = 1 }})
    TestGroup:new("Group_Mid_D", { Groups = {Group_Top = 2 }})

    TestGroup:new("Group_Bottom_A1", { Groups = {Group_Mid_A = 3 }})
    TestGroup:new("Group_Bottom_A2", { Groups = {Group_Mid_A = 3 }})

    TestGroup:new("Group_Bottom_B1", { Groups = {Group_Mid_B = 1 }})
    TestGroup:new("Group_Bottom_B2", { Groups = {Group_Mid_B = 0 }})

    TestGroup:new("Group_Bottom_C1", { Groups = {Group_Mid_C = 1 }})

    TestGroup:new("Group_Bottom_BC1", { Groups = {Group_Mid_B = 1, Group_Mid_C = 1 }})

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


-- ######################################################################
-- print results
Tests.counts()

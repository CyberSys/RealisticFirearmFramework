--[[- Main sub-module importer.

@module RFF
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
-- best not to assume our module path is in a standard spot, so check for a global env constant
if not ENV_RFF_PATH then
    ENV_RFF_PATH = "rff/"
end

local RFF = { }
RFF.Const = require(ENV_RFF_PATH .. "constants")
RFF.Config = require(ENV_RFF_PATH .. "config")
RFF.Interface = require(ENV_RFF_PATH .. "interface/init")
RFF.EventSystem = require(ENV_RFF_PATH .. "events")

RFF.ItemGroup = require(ENV_RFF_PATH .. "item_group")
RFF.ItemType = require(ENV_RFF_PATH .. "item_type")

RFF.Ammo = require(ENV_RFF_PATH .. "ammo/init")
--RFF.AmmoGroup = require(ENV_RFF_PATH .. "ammo/group")
--RFF.AmmoType = require(ENV_RFF_PATH .. "ammo/type")

RFF.Magazine = require(ENV_RFF_PATH .. "magazine/init") 

RFF.Firearm = require(ENV_RFF_PATH .. "firearm/init")
--RFF.FirearmGroup = require(ENV_RFF_PATH .. "firearm/group")
--RFF.FirearmType = require(ENV_RFF_PATH .. "firearm/type")

return RFF

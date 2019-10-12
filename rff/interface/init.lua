--[[- Interface sub-module importer.

@module RFF.Interface
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]

local Interface = {
    Bit = require(ENV_RFF_PATH .. "interface/bit32"),
    Container = require(ENV_RFF_PATH .. "interface/container"),
    Firearm = require(ENV_RFF_PATH .. "interface/firearm"),
    Logger = require(ENV_RFF_PATH .. "interface/logger"),
    Player = require(ENV_RFF_PATH .. "interface/player"),
}


return Interface

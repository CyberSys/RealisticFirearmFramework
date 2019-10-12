--[[- Bitwise feature flags for firearms.

@module RFF.Firearm.Flags
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]
local Flags = {}

--- Design Features Flags
-- @section DesignFeatureFlags

--- can cock manually, requires cocking before firing if not also DOUBLEACTION
Flags.SINGLEACTION = 1
--- auto cocks on trigger pull.
Flags.DOUBLEACTION = 2
--- has a select-fire mode switch.
Flags.SELECTFIRE = 4
--- switch has a semi auto position. for non-select fires this is not needed.
Flags.SEMIAUTO = 8
--- switch has a full auto position. this must be set for weapons always fullauto
Flags.FULLAUTO = 16
--- switch has a 2 shot burst position
Flags.BURST2 = 32
--- switch has a 3 shot burst position
Flags.BURST3 = 64
--- gun has a manual safety
Flags.SAFETY = 128
--- slide/bolt locks open after last shot. automatics only.
Flags.SLIDELOCK = 256
--- gun has a loaded chamber indicator
Flags.CHAMBERINDICATOR = 512
--- gun is a open-bolt design.
Flags.OPENBOLT = 1024
--- gun is a bullpup design.
Flags.BULLPUP = 2048
-- Flags.COCKED = 4096 -- gun is currently cocked.
--- gun has a free floating barrel.
Flags.FREEFLOAT = 8192
--- gun has no built in sights.
Flags.NOSIGHTS = 16384
--- gun can slamfire intentionally
Flags.SLAMFIRE = 32768
--- gun has a ported barrel
Flags.PORTED = 65536

--- Feed System Flags
-- @section FeedSystemFlags

--- gun is a automatic
Flags.AUTO = 1
--- gun is a bolt action
Flags.BOLT = 2
--- gun is a lever action
Flags.LEVER = 4
--- gun is a pump action
Flags.PUMP = 8
--- gun is a break-barrel/breach-loader.
Flags.BREAK = 16
--- gun uses a rotary cylinder
Flags.ROTARY = 32
--- gun is a blowback automatic
Flags.BLOWBACK = 64
--- gun is a delayed blowback automatic
Flags.DELAYEDBLOWBACK = 128
--- gun is a short piston gas fed automatic
Flags.SHORTGAS = 256
--- gun is a long piston gas fed automatic
Flags.LONGGAS = 512
--- gun is a direct impingement gas fed automatic
Flags.DIRECTGAS = 1024
--- gun is a long recoil automatic
Flags.LONGRECOIL = 2048
--- gun is a short recoil automatic
Flags.SHORTRECOIL = 4096
--- gas fed system with adjustable value
Flags.GASVALVE = 8192


Flags.TRIGGER_TYPES = Flags.SINGLEACTION + Flags.DOUBLEACTION
return Flags

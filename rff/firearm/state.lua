--[[- Bitwise Flags for defining the current state of a firearm.

@module RFF.Firearm.State
@author Fenris_Wolf
@release 1.0-alpha
@copyright 2018

]]

local State = {}

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

-- bolt will not close (or open, depending on state.)
State.FEEDJAMMED = 2048 
-- squib loaded barrel
State.BARRELJAMMED = 4096 


State.FIREMODESTATES = State.SINGLESHOT + State.FULLAUTO + State.BURST2 + State.BURST3
return State

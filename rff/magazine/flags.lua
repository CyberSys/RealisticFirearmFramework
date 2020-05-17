local Flags = { }

Flags.INTERNAL = 1
Flags.LOADGATE = 2 -- internal magazines. has a loading gate primarly for (tubes, old revolvers) 
Flags.FIXED = 4 -- internal mags. loading gate must be used. (cylnder doesnt swing out, tube doesnt slide) 
Flags.ROTARY = 8
Flags.TUBE = 16
--Flags.TUBE = 32

Flags.BOX = 64
Flags.DRUM = 128
Flags.CASKET = 256

Flags.STEEL = 512
Flags.POLYMER = 1024
Flags.PEEKSTRIP = 2048
Flags.BULK = 4096
Flags.MATCHGRADE = 8192

return Flags

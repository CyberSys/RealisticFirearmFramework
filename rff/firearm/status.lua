local Status = {}
Status.SINGLESHOT = 8 -- Singleshot or semi auto mode
Status.FULLAUTO = 16 -- full-atuo mode.
Status.BURST2 = 32 -- fire 2 shot bursts
Status.BURST3 = 64 -- fire 3 shot bursts
Status.SAFETY = 128 -- manual safety
Status.OPEN = 256 -- slide/bolt is open.
Status.COCKED = 512 -- gun is currently cocked
Status.FORCEOPEN = 1024 -- user specifically requested gun should be open. To prevent normal reloading from auto racking.

return Status

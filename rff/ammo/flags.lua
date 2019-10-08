local Flags = {}

Flags.RIMFIRE = 1 -- rimfire cartridge
Flags.PISTOL = 2 -- 'pistol' calibers
Flags.RIFLE = 4 -- 'rifle' calibers
Flags.SHOTGUN = 8 -- shotgun shells
-- variant specific
Flags.HOLLOWPOINT = 16 -- hollow point
Flags.JACKETED = 32 -- jacketed, partial or full
Flags.SOFTPOINT = 64 -- lead tipped bullet
Flags.FLATPOINT = 128 -- flat tipped bullet
Flags.MATCHGRADE = 256 -- high quality
Flags.BULK = 512 -- cheap low quality
Flags.SURPLUS = 1024 -- military, domestic or foreign
Flags.SUBSONIC = 2048 -- subsonic ammo. cheap hack. this often depends on barrel length
Flags.STEELCORE = 4096 -- solid steelcore
Flags.BIRDSHOT = 8192 --
Flags.BUCKSHOT = 16384 --
Flags.SLUG = 32768 --

return Flags

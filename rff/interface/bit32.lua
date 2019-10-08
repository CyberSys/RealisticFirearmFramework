local Bit32 = {}


if bit32 then -- check for lua 5.2 compat
    Bit32.band = bit32.band
else -- application can overwrite
    Bit32.band = function(a, b)
        return
    end
end

return Bit32
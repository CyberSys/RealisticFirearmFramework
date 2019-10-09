local Bit32 = {}


if bit32 then -- check for lua 5.2 compat
    Bit32.band = bit32.band
    Bit32.bxor = bit32.bxor
    Bit32.bor = bit32.bor
else -- application can overwrite
    Bit32.band = function(a, b)
        return
    end
    Bit32.bxor = function(a, b)
        return
    end
    Bit32.bor = function(a, b)
        return
    end
end

return Bit32
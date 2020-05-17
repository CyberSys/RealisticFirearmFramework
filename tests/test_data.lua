local Const = require(ENV_RFF_PATH .. "constants")
local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local Ammo = require(ENV_RFF_PATH .. "ammo/init")
local Magazine = require(ENV_RFF_PATH .. "magazine/init")

local TestData = { }
TestData.AmmoGroups = {
    AmmoGroup_357Magnum = { },
    AmmoGroup_556x45mm = { },
}
TestData.Ammo = {
    Ammo_357Magnum_Type1 = {
        case = "Case_357Magnum",
        groups = { AmmoGroup_357Magnum = 1, },
        case_mass = 1, bullet_mass = 1, powder_mass = 1, powder_type = "",
        category = Ammo.Flags.PISTOL,
        features = Ammo.Flags.JACKETED + Ammo.Flags.HOLLOWPOINT + Ammo.Flags.FLATPOINT,
    },

    Ammo_357Magnum_Type2 = {
        case = "Case_357Magnum",
        groups = { AmmoGroup_357Magnum = 1, },
        case_mass = 1, bullet_mass = 1, powder_mass = 1, powder_type = "",
        category = Ammo.Flags.PISTOL,
        features = Ammo.Flags.JACKETED + Ammo.Flags.FLATPOINT,
    },
    
    Ammo_556x45mm_Type1 = {
        case = "Case_556x45mm",
        groups = { AmmoGroup_556x45mm = 1, },
        case_mass = 1, bullet_mass = 1, powder_mass = 1, powder_type = "",
        category = Ammo.Flags.RIFLE,
        features = Ammo.Flags.JACKETED,
    },
}

TestData.MagazineGroups = {
    MagazineGroup_STANAG = { },
}
TestData.Magazines = {
    STANAGx20 = {
        weight = 0.2,
        groups = { MagazineGroup_STANAG = 1 },
        max_capacity = 20,
        ammo_group = "AmmoGroup_556x45mm",
        features = Magazine.Flags.BOX,
    },
    STANAGx30 = {
        weight = 0.2,
        groups = { MagazineGroup_STANAG = 1 },
        max_capacity = 30,
        ammo_group = "AmmoGroup_556x45mm",
        features = Magazine.Flags.BOX,
    }
}

TestData.Firearms = {
    Revolver1 = {
        weight = 1,
        barrel_length = 6,
        max_capacity = 6,
        category = Const.REVOLVER,
        feed_system = Firearm.Flags.ROTARY,
        features = Firearm.Flags.SINGLEACTION + Firearm.Flags.DOUBLEACTION + Firearm.Flags.SAFETY,
        ammo_group = "AmmoGroup_357Magnum",
    },
    
    
    SemiAutoRifle1 = {
        weight = 3.3,
        barrel_length = 20,
        -- max_capacity = 6,
        category = Const.RIFLE,
        magazine_group = nil,
        feed_system = Firearm.Flags.AUTO + Firearm.Flags.DIRECTGAS,
        features = Firearm.Flags.DOUBLEACTION + Firearm.Flags.SAFETY,
        ammo_group = "AmmoGroup_556x45mm",
    }

}

return TestData

--[[

local Const = require(ENV_RFF_PATH .. "constants")
local Firearm = require(ENV_RFF_PATH .. "firearm/init")
local FirearmType = require(ENV_RFF_PATH .. "firearm/type")
local FirearmGroup = require(ENV_RFF_PATH .. "firearm/group")
local Flags = require(ENV_RFF_PATH .. "firearm/flags")

FirearmGroup:new("Group_Main")
FirearmGroup:new("Group_RareCollectables")

FirearmGroup:new("Group_Classifications",   { Groups = { Group_Main = 1, } })
FirearmGroup:new("Group_Rifles",            { Groups = { Group_Classifications = 20, } })

FirearmGroup:new("Group_Manufacturers",     { Groups = { Group_Main = 1, } })
FirearmGroup:new("Group_Colt",              { Groups = { Group_Manufacturers = 1, } })
FirearmGroup:new("Group_Colt_Rifles",       { Groups = { Group_Rifles = 1, Group_Colt           = 1 } })

FirearmGroup:new("Group_Colt_CAR15",                    { Groups = { Group_Colt_Rifles = 1, } })


FirearmType:newCollection("Colt_CAR15", {
        category = Const.RIFLE,

        ammo_group = "AmmoGroup_556x45mm",
        magazine_group = "MagGroup_STANAG",
        weight = 3.3,
        barrel_length = 20,
        max_capacity = 30,

        classification = "IGUI_Firearm_AssaultRifle",
        country = "IGUI_Firearm_Country_US",
        manufacturer = "IGUI_Firearm_Manuf_Colt",
        description = "IGUI_Firearm_Desc_M16",
        feed_system = Flags.AUTO + Flags.DIRECTGAS,
        features = Flags.DOUBLEACTION + Flags.SLIDELOCK + Flags.SAFETY + Flags.SELECTFIRE + Flags.SEMIAUTO,

    }, {
        M601 = { -- Colt AR-15 Model 601
            year = 1959,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },

        M604 = { -- Colt M16 Model 604
            year = 1964,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },
        M603 = { -- Colt M16A1 Model 603
            year = 1967,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },
        M605A = { -- Colt CAR-15 Carbine Model 605A
            year = 1962,
            Groups = { Group_Colt_CAR15 = 1 },
            barrelLength = 15,
            additional_features = Flags.FULLAUTO,
        },
        M605B = { -- Colt CAR-15 Carbine Model 605B
            year = 1966,
            Groups = { Group_Colt_CAR15 = 1 },
            barrelLength = 15,
            additional_features = Flags.FULLAUTO + Flags.BURST3,
        },
        M607 = { -- Colt CAR-15 SMG Model 607
            year = 1966,
            barrelLength = 10,
            additional_features = Flags.FULLAUTO,
            Groups = { Group_Colt_CAR15 = 1, Group_RareCollectables = 50, }, -- 50 manufactured
        },
        M645 = { -- M16A2 Colt Model 645
            year = 1982,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.BURST3,
        },
        M646 = { -- M16A3 Colt Model 646
            year = 1982,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },
        M945 = { -- M16A4 Colt Model 945
            year = 1998,
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.BURST3,
        },
        M920 = { -- M4 Model 920
            barrelLength = 14.5,
            Icon = "Colt_CAR15_M4",
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.BURST3,
            --classification = "IGUI_Firearm_AssaultCarbine",
            year = 1984,
            --country = "IGUI_Firearm_Country_US",
            --manufacturer = "IGUI_Firearm_Manuf_Colt",
            --description = "IGUI_Firearm_Desc_M4C",
        },
        M921 = { -- M4A1 Model 921
            barrelLength = 14.5,
            Icon = "Colt_CAR15_M4",
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },
        M933 = { -- M4 Commando Model 933
            barrelLength = 11.5,
            Icon = "Colt_CAR15_M4",
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.FULLAUTO,
        },
        M935 = { -- M4 Commando Model 935
            barrelLength = 11.5,
            Icon = "Colt_CAR15_M4",
            Groups = { Group_Colt_CAR15 = 1 },
            additional_features = Flags.BURST3,
        },
})
]]

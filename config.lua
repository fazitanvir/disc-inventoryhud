Config = {}

Config.Locale = 'en'
Config.OpenControl = 289
Config.TrunkOpenControl = 47
Config.DeleteDropsOnStart = true
Config.HotKeyCooldown = 1000
Config.CheckLicense = true
Config.BagItem = 'bag'
Config.BagSkinCommand = 'bag'

--Durability Settings111
Config.TimerQuality = 10

Config.DurabilityInvs = {
    [1] = {name = "motel"},
    [2] = {name = "trunk"},
    [2] = {name = "bag"}
}

Config.ItemDurabilityList = {
    ["WEAPON_PISTOL"] = {QualityUse = true, outdated = 1.02, usable = true},
    ["WEAPON_HEAVYPISTOL"] = {QualityUse = true, outdated = 1.02, usable = true},
    ["WEAPON_ASSAULTRIFLE"] = {QualityUse = true, outdated = 1.02, usable = true},
    ["WEAPON_SNSPISTOL"] = {QualityUse = true, outdated = 0.02, usable = true},
    ["WEAPON_APPISTOL"] = {QualityUse = true, outdated = 1.02, usable = true},
    ["WEAPON_MACHINEPISTOL"] = {QualityUse = true, outdated = 0.02, usable = true},
    ["WEAPON_MICROSMG"] = {QualityUse = true, outdated = 0.02, usable = true},
    ["WEAPON_SMG"] = {QualityUse = true, outdated = 0.02, usable = true},
    ["WEAPON_CARBINERIFLE"] = {QualityUse = true, outdated = 1,02, usable = true},
    ["WEAPON_PISTOL50"] = {QualityUse = true, outdated = 1, usable = true},
}

Config.ItemSerialList = {
    ["WEAPON_PISTOL"] = {SerialUse = true},
    ["WEAPON_SNSPISTOL"] = {SerialUse = true},
    ["WEAPON_APPISTOL"] = {SerialUse = true},
    ["WEAPON_HEAVYPISTOL"] = {SerialUse = true},
    ["WEAPON_ASSAULTRIFLE"] = {SerialUse = true},
    ["WEAPON_SWITCHBLADE"] = {SerialUse = true},
    ["WEAPON_MACHINEPISTOL"] = {SerialUse = true},
    ["WEAPON_SMG"] = {SerialUse = true},
    ["WEAPON_CARBINERIFLE"] = {SerialUse = true},
    ["WEAPON_PISTOL50"] = {SerialUse = true},
    --["cyber_ammo_pistol"] = {SerialUse = true},
}

Config.ItemUniqList = {
    ["bag"] = {auto = true, writesql = false}, --don't touch
    [""] = {auto = false, writesql = true, sql = 'insert', table = 'phone_uniq'},
}
--
Config.Shops = {
    ['Ammunation'] = {
        coords = {
            vector3(22.11, -1107.23, 29.8),
        },
        items = {
            { name = "WEAPON_PISTOL", price = 20, count = 1 },
            { name = "disc_ammo_pistol", price = 10, count = 1 },

        },
        markerType = 27,
        markerColour = { r = 255, g = 255, b = 255 },
        blipColour = 2,
        blipSprite = 110,
        msg = 'Press [~r~ E ~s~] to open the weaponshop.',
        enableBlip = true,
        job = 'all'
    },
	['Accessories'] = {
        coords = {
            vector3(18.63, -1110.03, 29.8),
        },
        items = {
            { name = "susturucu", price = 20, count = 1 },
            { name = "fener", price = 10, count = 1 },
			{ name = "uzatilmis", price = 20, count = 1 },
			{ name = "tutamac", price = 10, count = 1 },
			{ name = "durbun", price = 10, count = 1 },
			{ name = "kaplama", price = 10, count = 1 },

        },
        markerType = 27,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Press [~r~ E ~s~] to open accessories shop.',
        enableBlip = false,
        job = 'all'
    },
    ['PDSILAH'] = {
        coords = {
            vector3(-1106.40, -826.015, 14.282),
        },
        items = {
            { name = "WEAPON_CARBINERIFLE", price = 1500, count = 1 },
            { name = "WEAPON_COMBATPISTOL", price = 200, count = 1 },
            { name = "WEAPON_PISTOL50", price = 1500, count = 1 },
            { name = "WEAPON_STUNGUN", price = 50, count = 1 },
            { name = "WEAPON_NIGHTSTICK", price = 50, count = 1 },
            { name = "WEAPON_FLASHLIGHT", price = 50, count = 1 },
            { name = "disc_ammo_pistol", price = 5, count = 2 },
            { name = "disc_ammo_smg", price = 20, count = 2 },
            { name = "disc_ammo_rifle", price = 30, count = 2 },
            { name = "SmallArmor", price = 50, count = 1 },
            { name = "radio", price = 10, count = 1 },
            { name = "gps", price = 10, count = 1 },
            { name = "bodycam", price = 10, count = 1 },
            { name = "bandage", price = 10, count = 3 },
            { name = "drone_flyer_7", price = 800, count = 1 },            
        },
        markerType = 20,
        markerColour = { r = 255, g = 0, b = 0 },
        blipColour = 2,
        blipSprite = 52,
        msg = '[~r~ E ~s~]  by pressing You can access the weapon store',
        enableBlip = false,
        job = 'all'
    },
    ['LTDgasoline'] = {
        coords = {
            vector3(1135.808, -982.281, 46.415),
            vector3(-1222.915, -906.983, 12.326),
            vector3(-1487.553, -379.107, 40.163),
            vector3(-2968.243, 390.910, 15.043),
            vector3(1166.024, 2708.930, 38.157),
            vector3(1392.562, 3604.684, 34.980),
        },
        items = {
            { name = "bread", price = 20, count = 10 },
            { name = "water", price = 10, count = 10 },
        },
        markerType = 1,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Open Shop ~INPUT_CONTEXT~',
        enableBlip = true,
        job = 'all'
    },
}

Config.Stash = {
    ['LSPD'] = {
        coords = vector3(-1102.82, -820.917, 14.282),
        size = vector3(1.0, 1.0, 1.0),
        job = 'police',
        markerType = 2,
        markerColour = { r = 255, g = 255, b = 255 },
        msg = 'Polis Deposu ~INPUT_CONTEXT~'
    },
}

Config.Steal = {
    black_money = false,
    cash = true
}

Config.Seize = {
    black_money = false,
    cash = true
}

Config.VehicleLimit = {
    ['Zentorno'] = 10,
    ['Panto'] = 1,
    ['Zion'] = 5
}

--Courtesy DoctorTwitch
Config.VehicleSlot = {
    [0] = 34, --Compact
    [1] = 48, --Sedan
    [2] = 50, --SUV
    [3] = 29, --Coupes
    [4] = 10, --Muscle
    [5] = 10, --Sports Classics
    [6] = 10, --Sports
    [7] = 0, --Super
    [8] = 2, --Motorcycles
    [9] = 56, --Off-road
    [10] = 58, --Industrial
    [11] = 50, --Utility
    [12] = 78, --Vans
    [13] = 0, --Cycles
    [14] = 0, --Boats
    [15] = 0, --Helicopters
    [16] = 0, --Planes
    [17] = 38, --Service
    [18] = 38, --Emergency
    [19] = 560, --Military
    [20] = 0, --Commercial
    [21] = 0 --Trains
}

Config.Throwables = {
    WEAPON_MOLOTOV = 615608432,
    WEAPON_GRENADE = -1813897027,
    WEAPON_STICKYBOMB = 741814745,
    WEAPON_PROXMINE = -1420407917,
    WEAPON_SMOKEGRENADE = -37975472,
    WEAPON_PIPEBOMB = -1169823560,
    WEAPON_SNOWBALL = 126349499
}

Config.FuelCan = 883325847

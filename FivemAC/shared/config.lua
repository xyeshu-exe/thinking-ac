-- =============================================
--          ADVANCED ANTI-CHEAT CONFIG
-- =============================================

Config = {}

-- ▸ General Settings
Config.Prefix          = "[Thinking AC]"  -- Log prefix
Config.BanMessage      = "You have been permanently banned from this server."
Config.KickMessage     = "You have been kicked by Anti-Cheat."
Config.ScreenshotOnDetect = false        -- Require screenshot-basic resource if true

-- ▸ Discord Webhook Logging
Config.Discord = {
    Enabled    = true,
    Webhook    = "YOUR_DISCORD_WEBHOOK_URL_HERE",   -- <-- Change this!
    BotName    = "Thinking AC Logger",
    AvatarURL  = "",
    Color      = 16711680,  -- Red
}

-- ▸ Speed Hack Detection
Config.SpeedHack = {
    Enabled         = true,
    MaxCarSpeed     = 120.0,   -- Maximum allowed vehicle speed (m/s) ~432 km/h
    MaxBikeSpeed    = 90.0,
    MaxBoatSpeed    = 60.0,
    MaxHeliSpeed    = 100.0,
    MaxPlaneSpeed   = 200.0,
    Action          = "ban",   -- "ban" | "kick" | "warn"
    Warnings        = 3,       -- Warnings before ban (if action is "warn")
}

-- ▸ NoClip / Godmode Detection
Config.NoClip = {
    Enabled = true,
    Action  = "ban",
}

Config.GodMode = {
    Enabled     = true,
    Action      = "ban",
    MinTrigger  = 5,    -- Times flagged before action taken
}

-- ▸ Weapon Modifications (Damage Modifier)
Config.WeaponMods = {
    Enabled     = true,
    MaxDamage   = 9999.0,   -- Damage above this is flagged
    Action      = "ban",
}

-- ▸ Blacklisted Weapons (weapon hash list)
Config.BlacklistedWeapons = {
    Enabled = true,
    Action  = "ban",
    List    = {
        `WEAPON_RAILGUN`,
        `WEAPON_MINIGUN`,
        `WEAPON_UNHOLY_HELLBRINGER`,
        `WEAPON_WIDOWMAKER`,
        `WEAPON_RAYMYSTERY`,
        `WEAPON_EMPLAUNCHER`,
        `WEAPON_HOMINGLAUNCHER`,
    },
}

-- ▸ Blacklisted Vehicles (spawn names)
Config.BlacklistedVehicles = {
    Enabled = true,
    Action  = "ban",
    List    = {
        "hydra",
        "lazer",
        "rhino",
        "khanjali",
        "stromberg",
        "ruiner2",
        "thruster",
        "oppressor2",
    },
}

-- ▸ Teleport Detection
Config.Teleport = {
    Enabled      = true,
    MaxDistance  = 500.0,   -- Max meters allowed to travel per tick
    Action       = "kick",
}

-- ▸ Explosion Spam Detection
Config.ExplosionSpam = {
    Enabled     = true,
    MaxPerMin   = 10,       -- Max explosions per minute allowed
    Action      = "ban",
}

-- ▸ Ping Limit
Config.Ping = {
    Enabled     = true,
    MaxPing     = 400,      -- ms
    Warnings    = 5,        -- Warnings before kick
    Action      = "kick",
}

-- ▸ Resource Protection
Config.ResourceProtection = {
    Enabled      = true,
    Action       = "ban",
    -- Resources that clients are NOT allowed to start
    BlacklistedResources = {
        "menyoo",
        "trainer",
        "simple-trainer",
        "enhanced-reborn",
        "lambda-menu",
        "eulen",
        "phantom-x",
        "mod-menu",
        "kiddions",
        "cherax",
    },
}

-- ▸ Admin / Whitelist settings
Config.Admins = {
    -- Add admin license identifiers here
    -- "license:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
}

-- ▸ Web Dashboard Settings
Config.WebPanel = {
    Enabled = true,
    Port    = 3000,                  -- Access via http://your-ip:3000/
    Token   = "CHANGE_ME_NOW_123",   -- Secret token for API access
}

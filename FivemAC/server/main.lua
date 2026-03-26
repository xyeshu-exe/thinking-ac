-- =============================================
--     SERVER - MAIN (server/main.lua)
-- =============================================

local playerData = {}

-- Initialise player data on join
AddEventHandler('playerJoining', function()
    local src = source
    playerData[src] = {
        name       = GetPlayerName(src),
        license    = GetLicense(src),
        warnings   = {},
        godWarnings = 0,
        lastPos    = nil,
        explosions = {},
    }
end)

-- Clean up on drop
AddEventHandler('playerDropped', function()
    playerData[source] = nil
end)

-- ─────────── PING MONITOR ───────────
if Config.Ping.Enabled then
    local pingWarnings = {}
    CreateThread(function()
        while true do
            Wait(10000)
            for _, src in ipairs(GetPlayers()) do
                local p = tonumber(GetPlayerPing(src))
                if p and p > Config.Ping.MaxPing then
                    pingWarnings[src] = (pingWarnings[src] or 0) + 1
                    if pingWarnings[src] >= Config.Ping.Warnings then
                        pingWarnings[src] = 0
                        KickPlayer(src, ("High ping: %dms"):format(p))
                        LogToDiscord("🔨 Kicked — High Ping", ("Kicked for high ping: **%dms**"):format(p), src, {["Threshold"] = Config.Ping.MaxPing})
                    else
                        TriggerClientEvent('ac:notify', src, ("%s High Ping Warning %d/%d: %dms"):format(
                            Config.Prefix, pingWarnings[src], Config.Ping.Warnings, p))
                    end
                else
                    pingWarnings[src] = 0
                end
            end
        end
    end)
end

-- ─────────── RECEIVE DETECTION REPORTS FROM CLIENT ───────────

-- Speed hack report
RegisterNetEvent('ac:speedHack')
AddEventHandler('ac:speedHack', function(speed, vehModel)
    local src = source
    if IsAdmin(src) then return end
    local action = Config.SpeedHack.Action
    local reason = ("Speed hack detected: %.1f m/s in %s"):format(speed, vehModel)
    LogToDiscord("🚨 Speed Hack", reason, src, {["Speed"] = ("%.1f m/s"):format(speed), ["Vehicle"] = vehModel})
    if action == "ban" then
        BanPlayer(src, reason)
    elseif action == "kick" then
        KickPlayer(src, reason)
    elseif action == "warn" then
        if WarnPlayer(src, reason, Config.SpeedHack.Warnings) then
            BanPlayer(src, reason)
        end
    end
end)

-- NoClip report
RegisterNetEvent('ac:noClip')
AddEventHandler('ac:noClip', function()
    local src = source
    if IsAdmin(src) then return end
    local reason = "NoClip detected"
    LogToDiscord("🚨 NoClip", reason, src)
    if Config.NoClip.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- God mode report
RegisterNetEvent('ac:godMode')
AddEventHandler('ac:godMode', function()
    local src = source
    if IsAdmin(src) then return end
    local data = playerData[src]
    if not data then return end
    data.godWarnings = (data.godWarnings or 0) + 1
    if data.godWarnings >= Config.GodMode.MinTrigger then
        data.godWarnings = 0
        local reason = "God mode / invincibility detected"
        LogToDiscord("🚨 God Mode", reason, src)
        if Config.GodMode.Action == "ban" then
            BanPlayer(src, reason)
        else
            KickPlayer(src, reason)
        end
    end
end)

-- Blacklisted weapon report
RegisterNetEvent('ac:blacklistedWeapon')
AddEventHandler('ac:blacklistedWeapon', function(weaponHash)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Blacklisted weapon: %s"):format(weaponHash)
    LogToDiscord("🚨 Blacklisted Weapon", reason, src, {["Weapon Hash"] = weaponHash})
    if Config.BlacklistedWeapons.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Blacklisted vehicle report
RegisterNetEvent('ac:blacklistedVehicle')
AddEventHandler('ac:blacklistedVehicle', function(model)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Blacklisted vehicle: %s"):format(model)
    LogToDiscord("🚨 Blacklisted Vehicle", reason, src, {["Vehicle"] = model})
    if Config.BlacklistedVehicles.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Teleport report
RegisterNetEvent('ac:teleport')
AddEventHandler('ac:teleport', function(dist)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Teleport detected: %.1f meters"):format(dist)
    LogToDiscord("🚨 Teleport", reason, src, {["Distance"] = ("%.1f m"):format(dist)})
    if Config.Teleport.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Explosion spam report
RegisterNetEvent('ac:explosionSpam')
AddEventHandler('ac:explosionSpam', function(count)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Explosion spam: %d explosions/min"):format(count)
    LogToDiscord("🚨 Explosion Spam", reason, src, {["Count"] = count})
    if Config.ExplosionSpam.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Resource protection report
RegisterNetEvent('ac:illegalResource')
AddEventHandler('ac:illegalResource', function(resName)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Illegal resource running: %s"):format(resName)
    LogToDiscord("🚨 Illegal Resource", reason, src, {["Resource"] = resName})
    if Config.ResourceProtection.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Weapon damage mod report
RegisterNetEvent('ac:weaponDamageMod')
AddEventHandler('ac:weaponDamageMod', function(dmg, weaponHash)
    local src = source
    if IsAdmin(src) then return end
    local reason = ("Weapon damage modifier detected: %.1f (weapon: %s)"):format(dmg, weaponHash)
    LogToDiscord("🚨 Weapon Modifier", reason, src, {["Damage"] = dmg, ["Weapon"] = weaponHash})
    if Config.WeaponMods.Action == "ban" then
        BanPlayer(src, reason)
    else
        KickPlayer(src, reason)
    end
end)

-- Notify event for client
RegisterNetEvent('ac:notify')

print("[Thinking AC] Server-side Anti-Cheat loaded.")

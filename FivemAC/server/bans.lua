-- =============================================
--     SERVER - BAN MANAGEMENT (bans.lua)
-- =============================================

local bans = {}

-- Load bans from KVP (key-value persistence)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    local banData = GetResourceKvpString("ac_bans")
    if banData then
        bans = json.decode(banData) or {}
    end
    print(("[Thinking AC] Loaded %d bans."):format(#bans))
end)

-- Save bans to KVP
local function SaveBans()
    SetResourceKvp("ac_bans", json.encode(bans))
end

-- Check if a connecting player is banned
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    Wait(0)
    local src = source
    local identifiers = GetPlayerIdentifiers(src)

    deferrals.update("Checking Anti-Cheat records...")
    Wait(100)

    for _, id in ipairs(identifiers) do
        for _, ban in ipairs(bans) do
            if ban.id == id then
                deferrals.done("You are banned from this server.\nReason: " .. (ban.reason or "Anti-Cheat") .. "\nDate: " .. (ban.date or "Unknown"))
                return
            end
        end
    end

    deferrals.done()
end)

-- Ban a player (server-side)
function BanPlayer(source, reason)
    if IsAdmin(source) then return end  -- never ban admins
    local identifiers = GetPlayerIdentifiers(source)
    local name = GetPlayerName(source)
    for _, id in ipairs(identifiers) do
        table.insert(bans, {
            id     = id,
            name   = name,
            reason = reason,
            date   = os.date("%Y-%m-%d %H:%M:%S"),
        })
    end
    SaveBans()
    DropPlayer(source, Config.BanMessage .. "\nReason: " .. reason)
    print(("[Thinking AC] BANNED: %s | Reason: %s"):format(name, reason))
end

-- Kick a player (server-side)
function KickPlayer(source, reason)
    if IsAdmin(source) then return end
    local name = GetPlayerName(source)
    DropPlayer(source, Config.KickMessage .. "\nReason: " .. reason)
    print(("[Thinking AC] KICKED: %s | Reason: %s"):format(name, reason))
end

-- Warn a player (server-side) - returns true if should now ban
local warnings = {}
function WarnPlayer(source, reason, maxWarnings)
    if IsAdmin(source) then return false end
    local license = GetLicense(source)
    warnings[license] = (warnings[license] or 0) + 1
    local count = warnings[license]
    TriggerClientEvent('ac:notify', source, ("%s WARNING %d/%d: %s"):format(Config.Prefix, count, maxWarnings, reason))
    print(("[Thinking AC] WARN %d/%d: %s | Reason: %s"):format(count, maxWarnings, GetPlayerName(source), reason))
    if count >= maxWarnings then
        warnings[license] = 0
        return true  -- caller should now ban
    end
    return false
end

-- Admin command: unban by license
RegisterCommand('ac_unban', function(source, args)
    if source ~= 0 and not IsAdmin(source) then return end
    local targetId = args[1]
    if not targetId then
        print("[Thinking AC] Usage: ac_unban <license:xxx>")
        return
    end
    for i, ban in ipairs(bans) do
        if ban.id == targetId then
            table.remove(bans, i)
            SaveBans()
            print(("[Thinking AC] Unbanned: %s"):format(targetId))
            return
        end
    end
    print(("[Thinking AC] No ban found for: %s"):format(targetId))
end, true)

-- Admin command: list bans
RegisterCommand('ac_bans', function(source, args)
    if source ~= 0 and not IsAdmin(source) then return end
    for i, ban in ipairs(bans) do
        print(("[Thinking AC] Ban #%d | ID: %s | Name: %s | Reason: %s | Date: %s"):format(
            i, ban.id, ban.name, ban.reason, ban.date))
    end
end, true)

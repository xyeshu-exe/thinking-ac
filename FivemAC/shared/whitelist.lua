-- =============================================
--           WHITELIST / ADMIN HELPERS
-- =============================================

-- Returns true if the source player is an admin
function IsAdmin(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        for _, admin in ipairs(Config.Admins) do
            if id == admin then
                return true
            end
        end
    end
    return false
end

-- Returns the player's license identifier
function GetLicense(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == "license:" then
            return id
        end
    end
    return "unknown"
end

-- Returns the player's discord identifier
function GetDiscordId(source)
    local identifiers = GetPlayerIdentifiers(source)
    for _, id in ipairs(identifiers) do
        if string.sub(id, 1, 8) == "discord:" then
            return id
        end
    end
    return "unknown"
end

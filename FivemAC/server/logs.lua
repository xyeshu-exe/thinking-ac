-- =============================================
--     SERVER - DISCORD LOGGING (logs.lua)
-- =============================================

local function MakeEmbed(title, description, color, fields)
    local embed = {
        {
            title       = title,
            description = description,
            color       = color or Config.Discord.Color,
            fields      = fields or {},
            footer      = { text = "Anti-Cheat System • " .. os.date("%Y-%m-%d %H:%M:%S") },
        }
    }
    return embed
end

-- Send log to Discord webhook
function LogToDiscord(title, description, source, extra)
    if not Config.Discord.Enabled then return end
    if Config.Discord.Webhook == "YOUR_DISCORD_WEBHOOK_URL_HERE" or Config.Discord.Webhook == "" then return end

    local fields = {}
    if source and source ~= 0 then
        table.insert(fields, { name = "Player",     value = GetPlayerName(source) or "Unknown", inline = true })
        table.insert(fields, { name = "License",    value = GetLicense(source),                inline = true })
        table.insert(fields, { name = "Discord",    value = GetDiscordId(source),              inline = true })
        table.insert(fields, { name = "Server ID",  value = tostring(source),                 inline = true })
    end
    if extra then
        for k, v in pairs(extra) do
            table.insert(fields, { name = tostring(k), value = tostring(v), inline = true })
        end
    end

    local payload = json.encode({
        username   = Config.Discord.BotName,
        avatar_url = Config.Discord.AvatarURL,
        embeds     = MakeEmbed(title, description, Config.Discord.Color, fields),
    })

    PerformHttpRequest(Config.Discord.Webhook, function(err, text, headers) end,
        'POST', payload, { ['Content-Type'] = 'application/json' })
end

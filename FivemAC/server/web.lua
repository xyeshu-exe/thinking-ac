-- =============================================
--   SERVER - WEB DASHBOARD API (server/web.lua)
-- =============================================
-- Access your dashboard at:
-- http://<your-server-ip>:<port>/
-- Port is set via Config.WebPanel.Port in config.lua
-- Default: http://localhost:3000/

local activeAlerts = {}   -- Recent alerts list
local playerStats  = {}   -- Per-player stats (set from main.lua)

-- Allow main.lua to push player stats into our table
function SetPlayerStat(src, data)
    playerStats[tostring(src)] = data
end

function ClearPlayerStat(src)
    playerStats[tostring(src)] = nil
end

function PushAlert(alert)
    table.insert(activeAlerts, 1, alert)
    if #activeAlerts > 100 then
        table.remove(activeAlerts)
    end
end

-- ─── AUTH MIDDLEWARE ───────────────────────────────────────
local function IsAuthorized(req)
    local token = (req.headers and req.headers["X-AC-Token"]) or
                  (req.query   and req.query["token"])
    return token == Config.WebPanel.Token
end

-- ─── CORS HEADERS ──────────────────────────────────────────
local CORS = {
    ["Access-Control-Allow-Origin"]  = "*",
    ["Access-Control-Allow-Headers"] = "Content-Type, X-AC-Token",
    ["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS",
    ["Content-Type"]                 = "application/json",
}

local function JsonResp(res, status, data)
    res.writeHead(status, CORS)
    res.send(json.encode(data))
end

-- ─── HTTP HANDLER ──────────────────────────────────────────
SetHttpHandler(function(req, res)
    local path = req.path or "/"

    -- Handle CORS pre-flight
    if req.method == "OPTIONS" then
        res.writeHead(200, CORS)
        res.send("")
        return
    end

    -- ─── SERVE STATIC WEB FILES ───────────────
    if path == "/" or path == "/index.html" then
        local html = LoadResourceFile(GetCurrentResourceName(), "web/index.html")
        if html then
            res.writeHead(200, { ["Content-Type"] = "text/html; charset=utf-8" })
            res.send(html)
        else
            res.writeHead(404, {})
            res.send("index.html not found")
        end
        return
    end

    if path == "/css/style.css" then
        local css = LoadResourceFile(GetCurrentResourceName(), "web/css/style.css")
        res.writeHead(200, { ["Content-Type"] = "text/css" })
        res.send(css or "")
        return
    end

    if path == "/js/app.js" then
        local js = LoadResourceFile(GetCurrentResourceName(), "web/js/app.js")
        res.writeHead(200, { ["Content-Type"] = "application/javascript" })
        res.send(js or "")
        return
    end

    if path == "/js/api.js" then
        local js = LoadResourceFile(GetCurrentResourceName(), "web/js/api.js")
        res.writeHead(200, { ["Content-Type"] = "application/javascript" })
        res.send(js or "")
        return
    end

    -- ─── AUTH CHECK FOR ALL API ROUTES ────────
    if not IsAuthorized(req) then
        JsonResp(res, 401, { error = "Unauthorized. Include X-AC-Token header or ?token= param." })
        return
    end

    -- ─── GET /api/players ─────────────────────
    if path == "/api/players" and req.method == "GET" then
        local players = {}
        for _, src in ipairs(GetPlayers()) do
            local srcNum = tonumber(src)
            players[#players + 1] = {
                id       = srcNum,
                name     = GetPlayerName(srcNum) or "Unknown",
                ping     = GetPlayerPing(srcNum),
                license  = GetLicense(srcNum),
                discord  = GetDiscordId(srcNum),
                identifiers = GetPlayerIdentifiers(srcNum),
            }
        end
        JsonResp(res, 200, players)
        return
    end

    -- ─── GET /api/alerts ──────────────────────
    if path == "/api/alerts" and req.method == "GET" then
        JsonResp(res, 200, activeAlerts)
        return
    end

    -- ─── GET /api/bans ────────────────────────
    if path == "/api/bans" and req.method == "GET" then
        local banData = GetResourceKvpString("ac_bans")
        local banList = banData and json.decode(banData) or {}
        JsonResp(res, 200, banList)
        return
    end

    -- ─── POST /api/ban ────────────────────────
    if path == "/api/ban" and req.method == "POST" then
        local body = req.body and json.decode(req.body) or {}
        local targetId = tonumber(body.id)
        local reason   = body.reason or "Banned via Web Panel"
        if not targetId then
            JsonResp(res, 400, { error = "Missing player id" })
            return
        end
        BanPlayer(targetId, reason)
        PushAlert({ type = "ban", player = GetPlayerName(targetId) or "Unknown", reason = reason, time = os.date("%H:%M:%S") })
        JsonResp(res, 200, { success = true })
        return
    end

    -- ─── POST /api/kick ───────────────────────
    if path == "/api/kick" and req.method == "POST" then
        local body = req.body and json.decode(req.body) or {}
        local targetId = tonumber(body.id)
        local reason   = body.reason or "Kicked via Web Panel"
        if not targetId then
            JsonResp(res, 400, { error = "Missing player id" })
            return
        end
        KickPlayer(targetId, reason)
        PushAlert({ type = "kick", player = GetPlayerName(targetId) or "Unknown", reason = reason, time = os.date("%H:%M:%S") })
        JsonResp(res, 200, { success = true })
        return
    end

    -- ─── POST /api/unban ──────────────────────
    if path == "/api/unban" and req.method == "POST" then
        local body = req.body and json.decode(req.body) or {}
        local targetLicense = body.license
        if not targetLicense then
            JsonResp(res, 400, { error = "Missing license" })
            return
        end
        local banData = GetResourceKvpString("ac_bans")
        local banList = banData and json.decode(banData) or {}
        local found = false
        for i, ban in ipairs(banList) do
            if ban.id == targetLicense then
                table.remove(banList, i)
                found = true
                break
            end
        end
        if found then
            SetResourceKvp("ac_bans", json.encode(banList))
            JsonResp(res, 200, { success = true })
        else
            JsonResp(res, 404, { error = "Ban not found" })
        end
        return
    end

    -- ─── GET /api/config ──────────────────────
    if path == "/api/config" and req.method == "GET" then
        -- Return a safe subset of config
        JsonResp(res, 200, {
            speedHack   = Config.SpeedHack,
            noClip      = Config.NoClip,
            godMode     = Config.GodMode,
            teleport    = Config.Teleport,
            ping        = Config.Ping,
            explosions  = Config.ExplosionSpam,
            weapons     = Config.BlacklistedWeapons,
            vehicles    = Config.BlacklistedVehicles,
            resources   = Config.ResourceProtection,
        })
        return
    end

    -- ─── POST /api/config ─────────────────────
    if path == "/api/config" and req.method == "POST" then
        local body = req.body and json.decode(req.body) or {}
        -- Apply runtime config changes (won't persist across restarts, edit config.lua for permanent)
        if body.speedHack then
            if body.speedHack.MaxCarSpeed  then Config.SpeedHack.MaxCarSpeed  = tonumber(body.speedHack.MaxCarSpeed)  end
            if body.speedHack.MaxBikeSpeed then Config.SpeedHack.MaxBikeSpeed = tonumber(body.speedHack.MaxBikeSpeed) end
            if body.speedHack.Enabled      ~= nil then Config.SpeedHack.Enabled = body.speedHack.Enabled end
            if body.speedHack.Action       then Config.SpeedHack.Action = body.speedHack.Action end
        end
        if body.ping then
            if body.ping.MaxPing  then Config.Ping.MaxPing  = tonumber(body.ping.MaxPing)  end
            if body.ping.Enabled  ~= nil then Config.Ping.Enabled = body.ping.Enabled end
        end
        if body.noClip then
            if body.noClip.Enabled ~= nil then Config.NoClip.Enabled = body.noClip.Enabled end
        end
        if body.godMode then
            if body.godMode.Enabled ~= nil then Config.GodMode.Enabled = body.godMode.Enabled end
        end
        if body.teleport then
            if body.teleport.MaxDistance then Config.Teleport.MaxDistance = tonumber(body.teleport.MaxDistance) end
            if body.teleport.Enabled ~= nil then Config.Teleport.Enabled = body.teleport.Enabled end
        end
        if body.explosions then
            if body.explosions.MaxPerMin then Config.ExplosionSpam.MaxPerMin = tonumber(body.explosions.MaxPerMin) end
            if body.explosions.Enabled ~= nil then Config.ExplosionSpam.Enabled = body.explosions.Enabled end
        end
        JsonResp(res, 200, { success = true, message = "Config updated at runtime. Restart resource to reset." })
        return
    end

    -- ─── POST /api/announce ───────────────────
    if path == "/api/announce" and req.method == "POST" then
        local body = req.body and json.decode(req.body) or {}
        local msg  = body.message or ""
        if msg == "" then
            JsonResp(res, 400, { error = "Empty message" })
            return
        end
        for _, src in ipairs(GetPlayers()) do
            TriggerClientEvent('ac:notify', tonumber(src), "[ADMIN] " .. msg)
        end
        JsonResp(res, 200, { success = true })
        return
    end

    -- ─── GET /api/stats ───────────────────────
    if path == "/api/stats" and req.method == "GET" then
        JsonResp(res, 200, {
            playerCount = #GetPlayers(),
            banCount    = #(json.decode(GetResourceKvpString("ac_bans") or "[]")),
            alertCount  = #activeAlerts,
            uptime      = GetGameTimer() / 1000,
        })
        return
    end

    -- 404
    JsonResp(res, 404, { error = "Unknown endpoint" })
end)

print("[Thinking AC] Web dashboard running on port defined in config.")

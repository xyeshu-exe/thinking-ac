-- =============================================
--  CLIENT - DETECTIONS (client/detections.lua)
-- =============================================

local playerPed    = PlayerPedId()
local lastPos      = nil
local explosionCount = 0
local explosionReset = 0

-- ─────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────
local function GetVehicleClass(veh)
    if not DoesEntityExist(veh) then return nil end
    return GetVehicleClassFromName(GetEntityModel(veh))
end

local function GetVehicleMaxSpeedLimit(veh)
    local class = GetVehicleClass(veh)
    if class == 14 then return Config.SpeedHack.MaxBoatSpeed
    elseif class == 15 then return Config.SpeedHack.MaxHeliSpeed
    elseif class == 16 then return Config.SpeedHack.MaxPlaneSpeed
    elseif class == 13 then return Config.SpeedHack.MaxBikeSpeed
    else return Config.SpeedHack.MaxCarSpeed
    end
end

-- ─────────────────────────────────────────────
--  MAIN DETECTION LOOP
-- ─────────────────────────────────────────────
AddEventHandler('ac:startDetections', function()

    -- ── SPEED HACK ──
    if Config.SpeedHack.Enabled then
        CreateThread(function()
            while true do
                Wait(1000)
                playerPed = PlayerPedId()
                if IsPedInAnyVehicle(playerPed, false) then
                    local veh   = GetVehiclePedIsIn(playerPed, false)
                    local speed = GetEntitySpeed(veh)
                    local limit = GetVehicleMaxSpeedLimit(veh)
                    if speed > limit then
                        local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
                        TriggerServerEvent('ac:speedHack', speed, model)
                    end
                end
            end
        end)
    end

    -- ── NOCLIP DETECTION ──
    if Config.NoClip.Enabled then
        CreateThread(function()
            while true do
                Wait(500)
                playerPed = PlayerPedId()
                if IsEntityInAir(playerPed)
                    and not IsPedInAnyVehicle(playerPed, false)
                    and not IsPedFalling(playerPed)
                    and not IsPedJumping(playerPed)
                    and not IsPedClimbing(playerPed)
                    and not IsPedSwimming(playerPed)
                    and GetEntitySpeed(playerPed) > 5.0 then
                    -- Check if moving horizontally without gravity (noclip-like)
                    local vel = GetEntityVelocity(playerPed)
                    if math.abs(vel.z) < 0.3 and (math.abs(vel.x) > 3.0 or math.abs(vel.y) > 3.0) then
                        TriggerServerEvent('ac:noClip')
                    end
                end
            end
        end)
    end

    -- ── GOD MODE DETECTION ──
    if Config.GodMode.Enabled then
        CreateThread(function()
            while true do
                Wait(2000)
                playerPed = PlayerPedId()
                -- God mode: player is invincible flag set
                if GetPlayerInvincible(PlayerId()) then
                    TriggerServerEvent('ac:godMode')
                end
            end
        end)
    end

    -- ── BLACKLISTED WEAPONS ──
    if Config.BlacklistedWeapons.Enabled then
        CreateThread(function()
            while true do
                Wait(1000)
                playerPed = PlayerPedId()
                local currentWeapon = GetSelectedPedWeapon(playerPed)
                for _, hash in ipairs(Config.BlacklistedWeapons.List) do
                    if currentWeapon == hash then
                        TriggerServerEvent('ac:blacklistedWeapon', currentWeapon)
                        RemoveAllPedWeapons(playerPed, true)
                        break
                    end
                end
            end
        end)
    end

    -- ── BLACKLISTED VEHICLES ──
    if Config.BlacklistedVehicles.Enabled then
        CreateThread(function()
            while true do
                Wait(2000)
                playerPed = PlayerPedId()
                if IsPedInAnyVehicle(playerPed, false) then
                    local veh   = GetVehiclePedIsIn(playerPed, false)
                    local model = string.lower(GetEntityModel(veh) .. "")
                    -- Compare by model hash
                    for _, vehName in ipairs(Config.BlacklistedVehicles.List) do
                        if GetHashKey(vehName) == GetEntityModel(veh) then
                            TriggerServerEvent('ac:blacklistedVehicle', vehName)
                            -- Eject and delete
                            TaskLeaveVehicle(playerPed, veh, 0)
                            Wait(500)
                            DeleteVehicle(veh)
                            break
                        end
                    end
                end
            end
        end)
    end

    -- ── TELEPORT DETECTION ──
    if Config.Teleport.Enabled then
        CreateThread(function()
            while true do
                Wait(500)
                playerPed = PlayerPedId()
                local currentPos = GetEntityCoords(playerPed)
                if lastPos then
                    local dist = #(currentPos - lastPos)
                    if dist > Config.Teleport.MaxDistance then
                        TriggerServerEvent('ac:teleport', dist)
                    end
                end
                lastPos = currentPos
            end
        end)
    end

    -- ── EXPLOSION SPAM DETECTION ──
    if Config.ExplosionSpam.Enabled then
        -- Count explosions caused by local player
        AddEventHandler('explosionEvent', function(ownerNetId, ev)
            -- ownerNetId of 0 means server, negative/own = player
            if ownerNetId == GetPlayerServerId(PlayerId()) then
                local now = GetGameTimer()
                if now - explosionReset > 60000 then
                    explosionCount = 0
                    explosionReset = now
                end
                explosionCount = explosionCount + 1
                if explosionCount > Config.ExplosionSpam.MaxPerMin then
                    TriggerServerEvent('ac:explosionSpam', explosionCount)
                    explosionCount = 0
                end
            end
        end)
    end

    -- ── RESOURCE PROTECTION ──
    if Config.ResourceProtection.Enabled then
        CreateThread(function()
            while true do
                Wait(5000)
                for _, resName in ipairs(Config.ResourceProtection.BlacklistedResources) do
                    if GetResourceState(resName) == "started" then
                        TriggerServerEvent('ac:illegalResource', resName)
                    end
                end
            end
        end)
    end

    -- ── WEAPON DAMAGE MOD DETECTION ──
    if Config.WeaponMods.Enabled then
        CreateThread(function()
            while true do
                Wait(3000)
                playerPed = PlayerPedId()
                local weapon = GetSelectedPedWeapon(playerPed)
                if weapon ~= `WEAPON_UNARMED` then
                    local dmg = GetWeaponDamage(weapon, 0)
                    if dmg and dmg > Config.WeaponMods.MaxDamage then
                        TriggerServerEvent('ac:weaponDamageMod', dmg, weapon)
                    end
                end
            end
        end)
    end

end) -- end ac:startDetections

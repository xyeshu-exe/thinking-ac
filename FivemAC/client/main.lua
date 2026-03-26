-- =============================================
--     CLIENT - MAIN (client/main.lua)
-- =============================================

local isLoaded = false

-- Wait until player is spawned
CreateThread(function()
    while not isLoaded do
        Wait(500)
        if LocalPlayer.state.isLoggedIn or NetworkIsSessionStarted() then
            isLoaded = true
        end
    end
    Wait(2000)
    print("[Thinking AC] Client Anti-Cheat active.")
    TriggerEvent('ac:startDetections')
end)

-- Show notification to local player
RegisterNetEvent('ac:notify')
AddEventHandler('ac:notify', function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end)

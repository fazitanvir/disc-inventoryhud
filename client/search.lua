local secondarySearchInventory = {
    type = 'player',
    owner = '',
    seize = true
}
local secondaryStealInventory = {
    type = 'player',
    owner = '',
    steal = true
}


RegisterNetEvent('disc-inventoryhud:steal')
AddEventHandler('disc-inventoryhud:steal', function()
    local player = ESX.GetPlayerData()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local searchPlayerPed = GetPlayerPed(closestPlayer)
        if IsEntityPlayingAnim(searchPlayerPed, 'mp_arresting', 'idle', 3) or IsEntityDead(searchPlayerPed) or GetEntityHealth(searchPlayerPed) <= 0 then
            ESX.TriggerServerCallback('disc-inventoryhud:getIdentifier', function(identifier)
                secondarySearchInventory.owner = identifier
                openInventory(secondarySearchInventory)
            end, GetPlayerServerId(closestPlayer))
        end
    end
end)

RegisterNetEvent('disc-inventoryhud:search')
AddEventHandler('disc-inventoryhud:search', function()
    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local searchPlayerPed = GetPlayerPed(closestPlayer)
        if IsEntityPlayingAnim(searchPlayerPed, 'random@mugging3', 'handsup_standing_base', 3) and not IsPedArmed(closestPlayer,7) then
            ESX.TriggerServerCallback('disc-inventoryhud:getIdentifier', function(identifier)
                secondaryStealInventory.owner = identifier
                openInventory(secondaryStealInventory)
            end, GetPlayerServerId(closestPlayer))
        end
    end
end)

Citizen.CreateThread(function(source, args, raw)
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 58) then
		        if IsPedArmed(GetPlayerPed(-1), 4) then
                TriggerEvent('disc-inventoryhud:steal')
			end
        end
    end
end)

Citizen.CreateThread(function(source, args, raw)
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 58) then
            if IsPedArmed(GetPlayerPed(-1), 4) then
			TriggerEvent('disc-inventoryhud:search')
            end
        end
    end
end)


RegisterNUICallback('StealCash', function(data)
    TriggerServerEvent('disc-inventoryhud:StealCash', data)
end)
RegisterNUICallback('SeizeCash', function(data)
    TriggerServerEvent('disc-inventoryhud:SeizeCash', data)
end)

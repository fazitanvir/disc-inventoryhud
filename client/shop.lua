local shopSecondaryInventory = {
    type = 'shop',
    owner = ''
}

Citizen.CreateThread(function()
    for k, v in pairs(Config.Shops) do
        if v.enableBlip then
            for val, coords in pairs(v.coords) do
                local blip = {
                    name = k,
                    coords = coords,
                    scale = 0.6,
                    colour = v.blipColour or 2,
                    sprite = v.blipSprite or 52
                }
                TriggerEvent('disc-base:registerBlip', blip)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while not ESXLoaded do
        Citizen.Wait(10)
    end
    for k, v in pairs(Config.Shops) do
        for val, coords in pairs(v.coords) do
            local marker = {
                name = k .. val,
                coords = coords,
                type = v.markerType or 1,
                colour = v.markerColour or { r = 55, b = 255, g = 55 },
                size = v.size or vector3(0.5, 0.5, 0.15),
                action = function()
                    local playerPed = GetPlayerPed(-1)
                    shopSecondaryInventory.owner = k
                    openInventory(shopSecondaryInventory)
                    if not IsEntityPlayingAnim(playerPed, 'pickup_object', 'putdown_low') then
                    ESX.Streaming.RequestAnimDict('pickup_object', function()
                    TaskPlayAnim(playerPed, 'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
                    Wait(1000)
                    ClearPedSecondaryTask(PlayerPedId())
                            end)
                        end
                    end,
                    shouldDraw = function()
                        return ESX.PlayerData.job.name == v.job or v.job == 'all'
                    end,
                    msg = v.msg or "Press ~INPUT_CONTEXT~ to open Shop",
                    show3D = true
                }
                TriggerEvent('disc-base:registerMarker', marker)
            end
        end
    end)
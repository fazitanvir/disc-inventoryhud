isHotKeyCoolDown = false
local UsedItemSlot = nil
local SlotW  = nil
local iName = nil
local SlotQua = nil 
RegisterNUICallback('UseItem', function(data)
    UsedItemSlot = data.slot
    ESX.TriggerServerCallback('disc-inventoryhud:LastSlot', function(result)
        if result then
            if isWeapon(data.item.id) then
                currentWeaponSlot = data.slot
                SlotW = data.slot
                iName = data.item.id
            end
            TriggerServerEvent('disc-inventoryhud:notifyImpendingRemoval', data.item, 1)
            TriggerServerEvent("esx:useItem", data.item.id)
            TriggerEvent('disc-inventoryhud:refreshInventory')
            if isWeapon(data.item.id) then
                data.item.msg = _U('holster')
            else
                data.item.msg = _U('used')
            end
            data.item.qty = 1
            TriggerEvent('disc-inventoryhud:showItemUse', {
                data.item
            })
        end
    end, UsedItemSlot)   
end)

RegisterNUICallback("PutIntoFast", function(data, cb)
    if data.slot ~= nil then
        fastWeapons[data.slot] = nil
    end
    fastWeapons[data.slot] = data.item.id
    loadPlayerInventory()
    cb("ok")
end)

RegisterNUICallback("TakeFromFast", function(data, cb)
    fastWeapons[data.slot] = nil
    if string.find(data.item.id, "WEAPON_", 1) ~= nil and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(data.item.name) then
        closeInventory()
        RemoveWeapon(data.item.id)
    end
    loadPlayerInventory()
    cb("ok")
end)

local keys = {
    157, 158, 160, 164, 165
}

RegisterNetEvent('disc-inventoryhud:deleteSerial')
AddEventHandler('disc-inventoryhud:deleteSerial', function()
    Citizen.Wait(10)
    if SlotW ~= nil then
        if iName ~= nil then
            TriggerServerEvent("disc-inventoryhud:deleteSerial", SlotW, iName)
        end
    end
end)

RegisterNetEvent('disc-inventoryhud:repairqua')
AddEventHandler('disc-inventoryhud:repairqua', function(slot)
    Citizen.Wait(10)
    TriggerServerEvent("disc-inventoryhud:repair", slot)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        BlockWeaponWheelThisFrame()
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        HideHudComponentThisFrame(17)
        DisableControlAction(0, 37, true) --Disable Tab
        for k, v in pairs(keys) do
            if IsDisabledControlJustReleased(0, v) then
                UseItem(k)
            end
        end
        if IsDisabledControlJustReleased(0, 37) then
            ESX.TriggerServerCallback('disc-inventoryhud:GetItemsInSlotsDisplay', function(items)
                SendNUIMessage({
                    action = 'showActionBar',
                    items = items
                })
            end)
        end
        if IsPedShooting(GetPlayerPed(-1)) then
            if SlotW ~= nil then
                if iName ~= nil then
                    ESX.TriggerServerCallback('disc-inventoryhud:CheckSlot', function(SlotQua)
                        if SlotQua.quality > 0 then
                            TriggerServerEvent("disc-inventoryhud:decrase", SlotW, iName)
                        else
                            RemoveWeaponFromPed(GetPlayerPed(-1), GetHashKey(iName))
                        end
                    end, SlotW)
                end
            end
        end
    end
end)

--[[RegisterNetEvent('disc-inventoryhud:bagskin')
AddEventHandler('disc-inventoryhud:bagskin', function(id)
    Citizen.Wait(0)
    --ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        --TriggerEvent('skinchanger:change', "bags_1", 44)
        --TriggerEvent('skinchanger:change', "bags_2", 0)
        TriggerServerEvent('esx_skin:save', skin)
        TriggerEvent('disc-inventoryhud:refreshInventory')
end)]]


RegisterNetEvent('disc-inventoryhud:bagskin')
AddEventHandler('disc-inventoryhud:bagskin', function(id)
    Citizen.Wait(0)
    --ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        --TriggerEvent('skinchanger:change', "bags_1", 44)
       -- TriggerEvent('skinchanger:change', "bags_2", 0)
        --TriggerServerEvent('esx_skin:save', skin)
        TriggerEvent('disc-inventoryhud:refreshInventory')
    --end)
end)

function UseItem(slot)
    if isHotKeyCoolDown then
        return
    end
    Citizen.CreateThread(function()
        isHotKeyCoolDown = true
        Citizen.Wait(Config.HotKeyCooldown)
        isHotKeyCoolDown = false
    end)
    ESX.TriggerServerCallback('disc-inventoryhud:UseItemFromSlot', function(item)
        if item then
            UsedItemSlot = slot
            ESX.TriggerServerCallback('disc-inventoryhud:LastSlot', function()
                if isWeapon(item.id) then
                    currentWeaponSlot = slot
                    SlotW = slot
                    iName = item.id
                end
                if (item.qua > 0) then
                    TriggerServerEvent('disc-inventoryhud:notifyImpendingRemoval', item, 1)
                    TriggerServerEvent("esx:useItem", item.id)
                    if isWeapon(item.id) then
                        item.msg = _U('holster')
                    else
                        item.msg = _U('used')
                    end
                    item.qty = 1
                    TriggerEvent('disc-inventoryhud:showItemUse', {
                        item,
                    })
                end
            end, UsedItemSlot)
        end
    end
    , slot)
end

RegisterNetEvent('disc-inventoryhud:showItemUse')
AddEventHandler('disc-inventoryhud:showItemUse', function(items)
    local data = {}
    for k, v in pairs(items) do
        table.insert(data, {
            item = {
                label = v.label,
                itemId = v.id
            },
            qty = v.qty,
            message = v.msg
        })
    end
    SendNUIMessage({
        action = 'itemUsed',
        alerts = data
    })
end)

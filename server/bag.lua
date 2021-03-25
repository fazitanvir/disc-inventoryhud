ESX = nil
local bags = {}

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

ESX.RegisterUsableItem(Config.BagItem, function(source)
    TriggerClientEvent('disc-inventoryhud:bag', source)
end)

Citizen.CreateThread(function()
    TriggerEvent('disc-inventoryhud:RegisterInventory', {
        name = 'bag',
        label = _U('Bag'),
        slots = 25,
        weight = 100
    })
end)

RegisterCommand(Config.BagSkinCommand, function(source)
    local _source = source
    TriggerClientEvent('disc-inventoryhud:bagskin', _source)
    TriggerClientEvent('disc-inventoryhud:refreshInventory', _source)
end)


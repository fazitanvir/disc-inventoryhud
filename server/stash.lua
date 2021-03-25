Citizen.CreateThread(function()
    TriggerEvent('disc-inventoryhud:RegisterInventory', {
        name = 'stash',
        label = 'Stash',
        slots = 100,
        weight = 2000
    })
end)


Citizen.CreateThread(function()
    TriggerEvent('inventory:RegisterInventory', {
        name = 'stash',
        label = _U('stash'),
        slots = 60
    })
end)

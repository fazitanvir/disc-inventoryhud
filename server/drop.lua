local drops = {}
local bags = {}

Citizen.CreateThread(function()
    TriggerEvent('disc-inventoryhud:RegisterInventory', {
        name = 'drop',
        label = _U('drop'),
        slots = 100,
        weight = 1000
    })
end)

MySQL.ready(function()
    if Config.DeleteDropsOnStart then
        MySQL.Async.execute('DELETE FROM disc_inventory WHERE type = \'drop\'')
        checkBags()
    end
end)

function checkBags()
    MySQL.Async.fetchAll('SELECT * FROM disc_inventory WHERE type = \'bag\'', {}, function(results)
        print('Bags ' .. tostring(#results))
        bags = {}
        for k, v in pairs(results) do
            if v.drop == '1' then
                MySQL.Sync.execute("DELETE FROM `disc_inventory` WHERE owner = @owner AND type = @type", { 
                    ['@owner'] = v.owner,
                    ['@type'] = 'bag'
                })
            end
        end
    end)
end

function updateDrops()
    print('Fetching')
    MySQL.Async.fetchAll('SELECT * FROM disc_inventory WHERE type = \'drop\'', {}, function(results)
        print('Fetched ' .. tostring(#results))
        drops = {}
        for k, v in pairs(results) do
            drops[v.owner] = json.decode(v.data)
        end
        table.print(drops)
        TriggerClientEvent('disc-inventoryhud:updateDrops', -1, drops)
    end)
end

Citizen.CreateThread(function()
    Citizen.Wait(5000)
    updateDrops()
end)

AddEventHandler('esx:playerLoaded', function(data)
    Citizen.Wait(0)
    updateDrops()
end)

RegisterServerEvent('disc-inventoryhud:modifiedInventory')
AddEventHandler('disc-inventoryhud:modifiedInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('disc-inventoryhud:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('disc-inventoryhud:savedInventory')
AddEventHandler('disc-inventoryhud:savedInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('disc-inventoryhud:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('disc-inventoryhud:createdInventory')
AddEventHandler('disc-inventoryhud:createdInventory', function(identifier, type, data)
    if type == 'drop' then
        drops[identifier] = data
        TriggerClientEvent('disc-inventoryhud:updateDrops', -1, drops)
    end
end)

RegisterServerEvent('disc-inventoryhud:deletedInventory')
AddEventHandler('disc-inventoryhud:deletedInventory', function(identifier, type)
    if type == 'drop' then
        drops[identifier] = nil
        TriggerClientEvent('disc-inventoryhud:updateDrops', -1, drops)
    end
end)

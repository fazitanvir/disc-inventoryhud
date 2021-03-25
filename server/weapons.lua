Citizen.CreateThread(function()
    Citizen.Wait(0)
    MySQL.Async.fetchAll('SELECT * FROM items WHERE LCASE(name) LIKE \'%weapon_%\'', {}, function(results)
        for k, v in pairs(results) do
            ESX.RegisterUsableItem(v.name, function(source)
                TriggerClientEvent('disc-inventoryhud:useWeapon', source, v.name)
            end)
        end
    end)
end)

RegisterServerEvent('disc-inventoryhud:updateAmmoCount')
AddEventHandler('disc-inventoryhud:updateAmmoCount', function(hash, count)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('UPDATE disc_ammo SET count = @count WHERE hash = @hash AND owner = @owner', {
        ['@owner'] = player.identifier,
        ['@hash'] = hash,
        ['@count'] = count
    }, function(results)
        if results == 0 then
            MySQL.Async.execute('INSERT INTO disc_ammo (owner, hash, count) VALUES (@owner, @hash, @count)', {
                ['@owner'] = player.identifier,
                ['@hash'] = hash,
                ['@count'] = count
            })
        end
    end)
end)

ESX.RegisterServerCallback('disc-inventoryhud:getAmmoCount', function(source, cb, hash)
    local _source = source
    local player = ESX.GetPlayerFromId(_source)
    MySQL.Async.fetchAll('SELECT * FROM disc_ammo WHERE owner = @owner and hash = @hash', {
        ['@owner'] = player.identifier,
        ['@hash'] = hash
    }, function(results)
        if #results == 0 then
            cb(nil)
        else
            cb(results[1].count, results[1].susturucu, results[1].fener, results[1].tutamac, results[1].kaplama, results[1].durbun, results[1].uzatilmis, ammoCount, susturucu, fener, tutamac, kaplama, durbun, uzatilmis)
        end
    end)
end)



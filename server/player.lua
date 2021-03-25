local ESX = nil
local impendingRemovals = {}
local impendingAdditions = {}
local itemQlist = nil
local itemSlist = nil
local itemUlist = nil
local uniqu = nil
local UsedLastSlot = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('disc-inventoryhud:getPlayerInventory', function(source, cb)
    getPlayerDisplayInventory(ESX.GetPlayerFromId(source).identifier, cb)
end)

ESX.RegisterServerCallback('disc-inventoryhud:getCanDownQ', function(source, cb)
    cb(itemQlist)
end)
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    itemQlist = Config.ItemDurabilityList
    itemSlist = Config.ItemSerialList
    itemUlist = Config.ItemUniqList
end)

ESX.RegisterServerCallback('disc-inventoryhud:CheckSlot', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    InvType['player'].getInventory(player.identifier, function(inventory)
        cb(inventory[tostring(slot)])
    end)
end)

RegisterServerEvent('disc-inventoryhud:decrase')
AddEventHandler('disc-inventoryhud:decrase', function(slot, item)
    local player = ESX.GetPlayerFromId(source)
    if player ~= nil then
        local originInvHandler = InvType['player']
        InvType['player'].getInventory(player.identifier, function(inventory)
            if itemQlist[inventory[tostring(slot)].name] ~= nil then
                local itemQualty = inventory[tostring(slot)].quality
                if itemQualty > 0 then
                    originInvHandler.applyToInventory(player.identifier, function(inventory2)
                        inventory2[tostring(slot)].quality = inventory2[tostring(slot)].quality - itemQlist[item].outdated
                    end)
                end
            end
        end)
    end
end)

RegisterServerEvent('disc-inventoryhud:decrasehand')
AddEventHandler('disc-inventoryhud:decrasehand', function(decreaseun ,slot)
    local player = ESX.GetPlayerFromId(source)
    if player ~= nil then
        local originInvHandler = InvType['player']
        InvType['player'].getInventory(player.identifier, function(inventory)
            if itemQlist[inventory[tostring(slot)].name] ~= nil then
                local itemQualty = inventory[tostring(slot)].quality
                if itemQualty > 0 then
                    originInvHandler.applyToInventory(player.identifier, function(inventory2)
                        inventory2[tostring(slot)].quality = inventory2[tostring(slot)].quality - decreaseun
                    end)
                end
            end
        end)
    end
end)
---------
RegisterServerEvent('disc-inventoryhud:repair')
AddEventHandler('disc-inventoryhud:repair', function(slot)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    InvType['player'].getInventory(player.identifier, function(inventory)
        if itemQlist[inventory[tostring(slot)].name] ~= nil then
            originInvHandler.applyToInventory(player.identifier, function(inventory2)
                inventory2[tostring(slot)].quality = 100
                local dctext = 'Eşya Tamir Edildi - ' .. inventory2[tostring(slot)].name
                TriggerEvent('disc:discord_log', player, dctext)
            end)
        else
            TriggerClientEvent('esx:showNotification', source, _U('uniqmatch'))
        end
    end)
end)

RegisterServerEvent('disc-inventoryhud:lowPerc')
AddEventHandler('disc-inventoryhud:lowPerc', function()
    local result2 = MySQL.Sync.fetchAll("SELECT * FROM users ", {})
    local result3 = MySQL.Sync.fetchAll("SELECT COUNT(*) AS ToplamDeger FROM users ", {})
    local maxwal = result3[1].ToplamDeger
    for i2 = 1, maxwal, 1 do
        local maxus = result2[i2].identifier
        InvType['player'].getInventory(maxus, function(inventory)
            for i = 1, 100, 1 do
                local item = inventory[tostring(i)]
                if item then
                    if itemQlist[item.name] ~= nil then
                        local originInvHandler = InvType['player']
                        local itemQualty = inventory[tostring(i)].quality
                        if itemQualty > 0 then
                            originInvHandler.applyToInventory(maxus, function(inventory2)
                                inventory2[tostring(i)].quality = inventory2[tostring(i)].quality - Config.TimerQuality
                            end)
                        end
                    end
                end
            end
        end)
    end
end)

RegisterServerEvent('disc-inventoryhud:lowPercS')
AddEventHandler('disc-inventoryhud:lowPercS', function()
    for k, v in pairs(Config.DurabilityInvs) do
        local loopv2 = MySQL.Sync.fetchAll("SELECT * FROM disc_inventory WHERE disc_inventory.type = @type ", {
            ['@type'] = v.name
        })
        local loopv1 = MySQL.Sync.fetchAll("SELECT COUNT(*) AS ToplamDeger FROM disc_inventory WHERE disc_inventory.type = @type ", {
            ['@type'] = v.name
        })
        local maxl = loopv1[1].ToplamDeger
        for i2 = 1, maxl, 1 do
            local ow = loopv2[i2].owner
            local invt = loopv2[i2].type
            InvType[invt].getInventory(ow, function(inventory)
                for i = 1, 100, 1 do
                    local item = inventory[tostring(i)]
                    if item then
                        if itemQlist[item.name] ~= nil then
                            local originInvHandler = InvType[invt]
                            local itemQualty = inventory[tostring(i)].quality
                            if itemQualty > 0 then
                                originInvHandler.applyToInventory(player.identifier, function(inventory2)
                                    inventory2[tostring(i)].quality = inventory2[tostring(i)].quality - Config.TimerQuality
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

function DecresaByTime()
    TriggerEvent("disc-inventoryhud:lowPerc")
    TriggerEvent("disc-inventoryhud:lowPercS")
end

TriggerEvent('disc:timer', 23, 59, DecresaByTime)

RegisterServerEvent('disc-inventoryhud:deleteSerial')
AddEventHandler('disc-inventoryhud:deleteSerial', function(slot, item)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    InvType['player'].getInventory(player.identifier, function(inventory)
        if itemSlist[item] ~= nil then
            originInvHandler.applyToInventory(player.identifier, function(inventory2)
                inventory2[tostring(slot)].serialnumber = "Silinimis"
                local dctext = 'Eşya Seri Numarası Sildirildi - ' .. inventory2[tostring(slot)].name
                TriggerEvent('disc:discord_log', player, dctext)
            end)
        end
    end)
end)

ESX.RegisterServerCallback('disc-inventoryhud:writeuniq', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    InvType['player'].getInventory(player.identifier, function(inventory)
        originInvHandler.applyToInventory(player.identifier, function(inventory2)
            if itemUlist[inventory2[tostring(slot)].name] ~= nil then
                uniqu = makeRandomNumberUniq()
                inventory2[tostring(slot)].uniq = uniqu
                local dctext = 'Eşya Uniq Yazdırıldı- ' .. inventory2[tostring(slot)].name
                TriggerEvent('disc:discord_log', player, dctext)
                cb(uniqu)
            else
                TriggerClientEvent('esx:showNotification', source, _U('uniqmatch'))
                cb(nil)
            end
        end)
    end)
end)

RegisterServerEvent('disc-inventoryhud:writeuniqhand')
AddEventHandler('disc-inventoryhud:writeuniqhand', function(slot, uniqu)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    InvType['player'].getInventory(player.identifier, function(inventory)
        if itemUlist[inventory2[tostring(slot)].name] ~= nil then
            originInvHandler.applyToInventory(player.identifier, function(inventory2)
                inventory2[tostring(slot)].uniq = uniqu
                local dctext = 'Eşya Uniq Yazdırıldı- ' .. inventory2[tostring(slot)].name
                TriggerEvent('disc:discord_log', player, dctext)            
            end)
        end
    end)
end)

ESX.RegisterServerCallback('disc-inventoryhud:LastSlot', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    if slot ~= nil then
        MySQL.Sync.execute("UPDATE `disc_inventory` SET `slot`=@slot WHERE owner = @identifier", { 
            ['@identifier'] = player.identifier,
            ['@slot'] = slot
        })
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('disc-inventoryhud:GetLastSlot', function(source, cb)
    local player = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT slot FROM disc_inventory WHERE owner = @owner', {
        ['@owner'] = player.identifier
    }, function(result)
        if result[1] ~= nil then
            cb(result[1].slot)
        else
            cb(nil)
        end
    end)
end)

ESX.RegisterServerCallback('disc-inventoryhud:getUniq', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    TriggerEvent('disc-inventory:saveInventory')
    InvType['player'].getInventory(player.identifier, function(inventory)
        originInvHandler.applyToInventory(player.identifier, function(inventory2)
            if itemUlist[inventory2[tostring(slot)].name] ~= nil then
                cb(inventory2[tostring(slot)].uniq)
            else
                cb(nil)
            end
        end)
    end)
end)

ESX.RegisterServerCallback('disc-inventoryhud:getItemName', function(source, cb, slot)
    local player = ESX.GetPlayerFromId(source)
    local originInvHandler = InvType['player']
    InvType['player'].getInventory(player.identifier, function(inventory)
        originInvHandler.applyToInventory(player.identifier, function(inventory2)
            cb(inventory2[tostring(slot)].name)
        end)
    end)
end)


Citizen.CreateThread(function()
    TriggerEvent('disc-inventoryhud:RegisterInventory', {
        name = 'player',
        label = _U('player'),
        slots = 50,
        weight = 100,
        getInventory = function(identifier, cb)
            getInventory(identifier, 'player', cb)
        end,
        saveInventory = function(identifier, inventory)
            saveInventory(identifier, 'player', inventory)
        end
    })
end)

function getPlayerDisplayInventory(identifier, cb)
    local player = ESX.GetPlayerFromIdentifier(identifier)
	local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE users.identifier = @identifier", {
		['@identifier'] = player.identifier
	})
	local charna = result[1].firstname .. " " .. result[1].lastname
    getInventory(identifier, 'player', function(inventory)
        local itemsObject = {}

        for k, v in pairs(inventory) do
            local esxItem = player.getInventoryItem(v.name)
            local item = createDisplayItem(v, esxItem, tonumber(k))
            table.insert(itemsObject, item)
        end
        local inv = {
            invId = identifier,
			labeln = player.source,
            charn = charna,
            listq = itemQlist,
            lists = itemSlist,
            invTier = InvType['player'],
            inventory = itemsObject,
            cash = player.getMoney(),
            bank = player.getAccount('bank').money,
            black_money = player.getAccount('black_money').money,
        }
        cb(inv)
    end)
end

function ensurePlayerInventory(player)
    loadInventory(player.identifier, 'player', function()
        TriggerClientEvent('disc-inventoryhud:refreshInventory', player.source)
    end)
end

function getCustomD(itemn)
    local getitem = MySQL.Sync.fetchAll("SELECT * FROM items WHERE items.name =@name", {
        ['@name'] = itemn
    })
    return getitem[1].durability
end

function makeRandomSer()
    math.randomseed(os.time())
    math.random(); math.random(); math.random();
    num = math.random(1000000000,9000000000)
    numtext = "LS" ..num.. "2020"
    return numtext
end

function makeRandomNumberUniq()
    math.randomseed(os.time())
    math.random(); math.random(); math.random();math.random();
    num = math.random(10000000000,90000000000)
    num2 = math.random(10000,90000)
    return num .. num2
end

RegisterServerEvent('disc-inventoryhud:notifyImpendingRemoval')
AddEventHandler('disc-inventoryhud:notifyImpendingRemoval', function(item, count, playerSource)
    local _source = playerSource or source
    if impendingRemovals[_source] == nil then
        impendingRemovals[_source] = {}
    end
    item.count = count
    local k = #impendingRemovals + 1
    impendingRemovals[_source][k] = item
    Citizen.CreateThread(function()
        Citizen.Wait(100)
        impendingRemovals[k] = nil
    end)
end)

RegisterServerEvent('disc-inventoryhud:notifyImpendingAddition')
AddEventHandler('disc-inventoryhud:notifyImpendingAddition', function(item, count, playerSource)
    local _source = playerSource or source
    if impendingAdditions[_source] == nil then
        impendingAdditions[_source] = {}
    end
    item.count = count
    local k = #impendingAdditions + 1
    impendingAdditions[_source][k] = item
    Citizen.CreateThread(function()
        Citizen.Wait(100)
        impendingAdditions[k] = nil
    end)
end)

AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
    local player = ESX.GetPlayerFromId(source)
    TriggerClientEvent('disc-inventoryhud:showItemUse', source, {
        { id = item.name, label = item.label, qty = count, msg = _U('removed') }
    })
    applyToInventory(player.identifier, 'player', function(inventory)
        if impendingRemovals[source] then
            for k, removingItem in pairs(impendingRemovals[source]) do
                if removingItem.id == item.name and removingItem.count == count then
                    if removingItem.block then
                        impendingRemovals[source][k] = nil
                    else
                        removeItemFromSlot(inventory, removingItem.slot, count)
                        impendingRemovals[source][k] = nil
                        TriggerClientEvent('disc-inventoryhud:refreshInventory', source)
                    end
                    return
                end
            end
        end
        local dctext = 'Eşya Silindi - ' ..item.name.. ' ,    miktarı - ' .. count
        TriggerEvent('disc:discord_log', player, dctext)
        for k, v in pairs(inventory) do
            if itemUlist[item.name] ~= nil then
                if itemUlist[item.name].writesql == true then
                    MySQL.Async.execute('DELETE FROM '..itemUlist[item.name].table..' WHERE uniq = @uniq', {
                        ['@uniq'] = inventory[k].uniq,
                    })
                end
            end
            if item.name == Config.BagItem then
                MySQL.Async.execute('DELETE FROM disc_inventory WHERE owner = @owner AND type = @type', {
                    ['@owner'] = inventory[k].uniq,
                    ['@type'] = 'bag'
                })
            end
        end
        removeItemFromInventory(item, count, inventory)
        TriggerClientEvent('disc-inventoryhud:refreshInventory', source)
    end)
end)

AddEventHandler('esx:onAddInventoryItem', function(source, esxItem, count)
    local player = ESX.GetPlayerFromId(source)
    TriggerClientEvent('disc-inventoryhud:showItemUse', source, {
        { id = esxItem.name, label = esxItem.label, qty = count, msg = _U('added') }
    })
    applyToInventory(player.identifier, 'player', function(inventory)
        if impendingAdditions[source] then
            for k, addingItem in pairs(impendingAdditions[source]) do
                if addingItem.id == esxItem.name and addingItem.count == count then
                    if addingItem.block then
                        impendingAdditions[source][k] = nil
                        return
                    end
                end
            end
        end
        local durability = getCustomD(esxItem.name)
        local serialnumber = nil
        local uniq = nil
        if itemSlist[esxItem.name] ~= nil then
            serialnumber = makeRandomSer()
            MySQL.Sync.execute("INSERT INTO `disc_serial_number`(`identifier`, `item`, `number`) VALUES (@identifier,@item,@number)", { 
                ['@identifier'] = player.identifier,
                ['@item'] = esxItem.name,
                ['@number'] = serialnumber
            })
        else
            serialnumber = "nil"
        end
        if itemUlist[esxItem.name] ~= nil then
            if itemUlist[esxItem.name].writesql == true then
                uniq = makeRandomNumberUniq()
                if itemUlist[esxItem.name].sql == "update" then
                    MySQL.Sync.execute("UPDATE `"..itemUlist[esxItem.name].table.."` SET `uniq`=@uniq WHERE identifier = @identifier", { 
                        ['@identifier'] = player.identifier,
                        ['@uniq'] = uniq
                    })
                elseif itemUlist[esxItem.name].sql == "insert" then
                    MySQL.Sync.execute("INSERT INTO `"..itemUlist[esxItem.name].table.."`(`identifier`, `uniq`) VALUES (@identifier,@uniq)", { 
                        ['@identifier'] = player.identifier,
                        ['@uniq'] = uniq
                    })
                end
            elseif itemUlist[esxItem.name].auto == true then
                uniq = makeRandomNumberUniq()
            else
                uniq = "nil"
            end
        else
            uniq = "nil"
        end
        if esxItem.name == Config.BagItem then
            MySQL.Sync.execute("INSERT INTO `disc_inventory`(`owner`, `type`, `data`, `drop`) VALUES (@owner,@type,@data,@drop)", { 
                ['@owner'] = uniq,
                ['@type'] = 'bag',
                ['@data'] = '{}',
                ['@drop'] = '0'
            })
        end
        if itemUlist[esxItem.name] ~= nil or itemSlist[esxItem.name] ~= nil then
        	count = 1
        end
        local dctext = 'Envanter Eşya Eklendi - ' ..esxItem.name.. ' ,    miktarı - ' ..count.. ' ,   Seri Numarası  - ' ..serialnumber .. ' ,   Durgunluk - ' .. durability .. ' ,   Uniq - ' .. uniq
        TriggerEvent('disc:discord_log', player, dctext)
        local item = createItem(esxItem.name, count, durability, serialnumber, uniq)
        addToInventory(item, 'player', inventory, esxItem.limit)
        if itemUlist[esxItem.name] ~= nil or itemSlist[esxItem.name] ~= nil then
            Citizen.Wait(2)
            TriggerEvent('disc-inventory:saveInventory')
        end
        TriggerClientEvent('disc-inventoryhud:refreshInventory', source)
    end)
end)

RegisterNetEvent('disc:discord_log')
AddEventHandler('disc:discord_log', function(xPlayer, text)
    local playerName = Sanitize(xPlayer.getName())
    
    local discord_webhook = GetConvar('discord_webhook', 'https://discordapp.com/api/webhooks/762451682432909313/eJHjZLKRGIs0yv_g-W4I4_2oiFFqb3vzAf0XVztS3sYhsoiL6L_eE0iZJwVgHH7m4XUw')
    if discord_webhook == '' then
      return
    end
    local headers = {
      ['Content-Type'] = 'application/json'
    }
    local data = {
      ["username"] = 'Envanter - Log ',
      ["avatar_url"] = 'https://media.discordapp.net/attachments/760296507521368065/760941308306653184/neco_dayg.jpg',
      ["embeds"] = {{
        ["author"] = {
          ["name"] = playerName .. ' - ' .. xPlayer.identifier
        },
        ["color"] = 14177041,
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
      }}
    }
    data['embeds'][1]['description'] = text
    PerformHttpRequest(discord_webhook, function(err, text, headers) end, 'POST', json.encode(data), headers)
end)

function Sanitize(str)
    local replacements = {
        ['&' ] = '&amp;',
        ['<' ] = '&lt;',
        ['>' ] = '&gt;',
        ['\n'] = '<br/>'
    }

    return str
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s)
            return ' '..('&nbsp;'):rep(#s-1)
        end)
end

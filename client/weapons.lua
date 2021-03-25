local currentWeapon
local currentWeaponSlot

RegisterNetEvent('disc-inventoryhud:useWeapon')
AddEventHandler('disc-inventoryhud:useWeapon', function(weapon)
    if currentWeapon == weapon then
        RemoveWeapon(currentWeapon)
        currentWeapon = nil
        currentWeaponSlot = nil
        return
    elseif currentWeapon ~= nil then
        RemoveWeapon(currentWeapon)
        currentWeapon = nil
        currentWeaponSlot = nil
    end
    currentWeapon = weapon
    GiveWeapon(currentWeapon)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('disc-inventoryhud:removeCurrentWeapon')
AddEventHandler('disc-inventoryhud:removeCurrentWeapon', function()
    if currentWeapon ~= nil then
        RemoveWeapon(currentWeapon)
        currentWeapon = nil
        currentWeaponSlot = nil
        ClearPedTasks(PlayerPedId())
    end
end)

function RemoveWeapon(weapon)
    local playerPed = GetPlayerPed(-1)
    local hash = GetHashKey(weapon)
    local ammoCount = GetAmmoInPedWeapon(playerPed, hash)
    TriggerServerEvent('disc-inventoryhud:updateAmmoCount', hash, ammoCount)
    RemoveWeaponFromPed(playerPed, hash)
end

supp1 = {-2084633992, -1357824103, 2132975508, -494615257}
supp2 = {-1716589765, 324215364, -270015777, -1074790547, -1063057011, -1654528753, 984333226}
supp3 = {1593441988, -771403250, 584646201, 137902532, 736523883}
supp4 = {487013001}
flash1 = {453432689, 1593441988, 584646201, -1716589765, -771403250, 324215364}
flash2 = {736523883, -270015777, 171789620, -1074790547, -2084633992, -1357824103, -1063057011, 2132975508, 487013001, -494615257, -1654528753, 984333226}
grip1 = {171789620, -1074790547, -2084633992, -1063057011, 2132975508, 2144741730, -494615257, -1654528753, 984333226}
scope1 = {-2084633992}

function GiveWeapon(weapon)
    local checkh = Config.Throwables
    local playerPed = GetPlayerPed(-1)
    local hash = GetHashKey(weapon)
    ESX.TriggerServerCallback('disc-inventoryhud:getAmmoCount', function(ammoCount, susturucu, fener, tutamac, kaplama, durbun, uzatilmis)
        GiveWeaponToPed(playerPed, hash, 1, false, true)

        if susturucu == 1 then
            if hash == GetHashKey("WEAPON_PISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("component_at_pi_supp_02"))
            elseif table.includes(supp1, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0x837445AA)
            elseif table.includes(supp2, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0xA73D4664)
            elseif table.includes(supp3, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0xC304849A)
            elseif table.includes(supp4, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0xE608B35E)
            end
        end

        if fener == 1 then
            if table.includes(flash1, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0x359B7AAE)
            elseif table.includes(flash2, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0x7BC4CDDC)
            end
        end

        if tutamac ==  1 then
            if table.includes(grip1, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0xC164F53)
            end
        end

        if kaplama == 1 then
            if hash == GetHashKey("WEAPON_PISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("COMPONENT_PISTOL_VARMOD_LUXE"))
            elseif hash == GetHashKey("WEAPON_PISTOL50") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL50"), GetHashKey("COMPONENT_PISTOL50_VARMOD_LUXE"))
            elseif hash == GetHashKey("WEAPON_APPISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), GetHashKey("COMPONENT_APPISTOL_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_HEAVYPISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYPISTOL"), GetHashKey("COMPONENT_HEAVYPISTOL_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_SMG") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SMG"), GetHashKey("COMPONENT_SMG_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_MICROSMG") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MICROSMG"), GetHashKey("COMPONENT_MICROSMG_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_CARBINERIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_CARBINERIFLE_VARMOD_LUXE"))

            elseif hash == GetHashKey("WEAPON_ADVANCEDRIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ADVANCEDRIFLE"), GetHashKey("COMPONENT_ADVANCEDRIFLE_VARMOD_LUXE"))
            end
        end
		
		if uzatilmis == 1 then
            if hash == GetHashKey("WEAPON_PISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL"), GetHashKey("COMPONENT_PISTOL_CLIP_02"))
            elseif hash == GetHashKey("WEAPON_PISTOL50") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_PISTOL50"), GetHashKey("COMPONENT_PISTOL50_CLIP_02"))    
            elseif hash == GetHashKey("WEAPON_APPISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_APPISTOL"), GetHashKey("COMPONENT_APPISTOL_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_HEAVYPISTOL") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_HEAVYPISTOL"), GetHashKey("COMPONENT_HEAVYPISTOL_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_SMG") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_SMG"), GetHashKey("COMPONENT_SMG_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_MICROSMG") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_MICROSMG"), GetHashKey("COMPONENT_MICROSMG_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_ASSAULTRIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ASSAULTRIFLE"), GetHashKey("COMPONENT_ASSAULTRIFLE_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_CARBINERIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_CARBINERIFLE"), GetHashKey("COMPONENT_CARBINERIFLE_CLIP_02"))
   
            elseif hash == GetHashKey("WEAPON_ADVANCEDRIFLE") then
                GiveWeaponComponentToPed(GetPlayerPed(-1), GetHashKey("WEAPON_ADVANCEDRIFLE"), GetHashKey("COMPONENT_ADVANCEDRIFLE_CLIP_02"))
            end
        end

        if durbun ==  1 then
            if table.includes(scope1, hash) then
                GiveWeaponComponentToPed(GetPlayerPed(-1), hash, 0xA0D89C42)
            end
        end

        if checkh[weapon] == hash then     
            SetPedAmmo(playerPed, hash, 1)
        elseif Config.FuelCan == hash and ammoCount == nil then
            SetPedAmmo(playerPed, hash, 1000)
        else
            SetPedAmmo(playerPed, hash, ammoCount or 0)
        end
    end, hash)
end

function table.includes(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local player = PlayerPedId()
        if IsPedShooting(player) then
            for k, v in pairs(Config.Throwables) do
                if k == currentWeapon then
                    print('Taking Weapon')
                    ESX.TriggerServerCallback('disc-base:takePlayerItem', function(removed)
                        if removed then
                            TriggerEvent('disc-inventoryhud:removeCurrentWeapon')
                        end
                    end, currentWeapon, 1)
                end
            end
        end
    end
end)
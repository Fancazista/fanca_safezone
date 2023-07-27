RegisterNetEvent("fanca_safezone:log")
AddEventHandler("fanca_safezone:log", function(zoneName, what, insideZoneTime)
    local player = source

    if not Config.Zones[zoneName] then
        -- The player triggered the event with an invalid zone name (POSSIBLE CHEATER)
        return
    end

    local ped = GetPlayerPed(player)
    local playerCoords = GetEntityCoords(ped)
    local distance

    if Config.Zones[zoneName].poly then
        distance = #(playerCoords - Config.Zones[zoneName].poly.points[1])
    elseif Config.Zones[zoneName].box then
        distance = #(playerCoords - Config.Zones[zoneName].box.coords)
    elseif Config.Zones[zoneName].sphere then
        distance = #(playerCoords - Config.Zones[zoneName].sphere.coords)
    elseif Config.Zones[zoneName].point then
        distance = #(playerCoords - Config.Zones[zoneName].point.coords)
    end

    if distance > 100.0 then
        -- The player triggered the event while being away from the area (POSSIBLE CHEATER)
        return
    end

    print(("^0[^5%s^0] ^0Player %d in zone %s (time=%s)."):format(what, player, zoneName, tostring(insideZoneTime)))
end)

RegisterNetEvent("fanca_safezone:kick")
AddEventHandler("fanca_safezone:kick", function(zoneName)
    local player = source

    if not Config.Zones[zoneName] then
        -- The player triggered the event with an invalid zone name (POSSIBLE CHEATER)
        return
    end

	DropPlayer(player, Config.afkDropMessage)
    print("^0[^5kicked^0]", ("^0Player %d kicked for being afk in zone '%s'."):format(player, zoneName))
end)

CreateThread(function()
    for zoneName,zoneData in pairs(Config.Zones) do
        if not Config.Types[zoneData.type] then
            return dprint("^0[^1ERROR^0]", ("^0Invalid zone type, report this problem to the server manager by providing the following data: zoneName='%s' | type='%s'."):format(zoneName, zoneData.type))
        end

        local defaultZoneCreate = {
            onEnter = OnEnter,
            onExit = OnExit,

            zoneName = zoneName,
            zoneData = zoneData,
            zonetype = Config.Types[zoneData.type],
            debug = zoneData.debug,
        }

        if zoneData.poly then
            defaultZoneCreate.inside = Inside
            defaultZoneCreate.points = zoneData.poly.points
            defaultZoneCreate.thickness = zoneData.poly.thickness

            Config.Zones[zoneName].zone = lib.zones.poly(defaultZoneCreate)
        elseif zoneData.box then
            defaultZoneCreate.inside = Inside
            defaultZoneCreate.coords = zoneData.box.coords
            defaultZoneCreate.size = zoneData.box.size
            defaultZoneCreate.rotation = zoneData.box.rotation

            Config.Zones[zoneName].zone = lib.zones.box(defaultZoneCreate)
        elseif zoneData.sphere then
            defaultZoneCreate.inside = Inside
            defaultZoneCreate.coords = zoneData.sphere.coords
            defaultZoneCreate.radius = zoneData.sphere.radius

            Config.Zones[zoneName].zone = lib.zones.sphere(defaultZoneCreate)
        elseif zoneData.point then
            defaultZoneCreate.nearby = Inside
            defaultZoneCreate.coords = zoneData.point.coords
            defaultZoneCreate.distance = zoneData.point.distance

            Config.Zones[zoneName].zone = lib.points.new(defaultZoneCreate)
        else
            return dprint("^0[^1ERROR^0]", ("^0Invalid zone structure type, report this problem to the server manager by providing the following data: zoneName=%s."):format(zoneName))
        end

        if zoneData.blip then
            local coords = defaultZoneCreate.coords

            if zoneData.poly then
                coords = getCenterPoint(zoneData.poly.points)
            end

            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

            SetBlipDisplay(blip, zoneData.blip.display)
            SetBlipSprite(blip, zoneData.blip.id)
            SetBlipColour(blip, zoneData.blip.color)
            SetBlipScale(blip, zoneData.blip.scale)

            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(zoneData.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

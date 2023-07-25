local insideZoneTime = 0
local stashedEntities = {}

---Notify system function
---@param txt any
---@param style string
local function notify(txt, style)
    lib.notify({description = txt, type = style, icon = "compass"})
end

---Function used to check if an entity is inside the zone
---@param self any
---@param entity any
---@return boolean
local function entityIsInZone(self, entity)
    if self.zoneData.point then
        local distance = #(self.coords - GetEntityCoords(entity))
        return (distance < self.zoneData.point.distance)
    else
        return (Config.Zones[self.zoneName].zone:contains(GetEntityCoords(entity)))
    end
end

---Used to disable collisions between two entities
local function DisableCollisionsThisFrame(one, two)
    SetEntityNoCollisionEntity(one, two, true)
    SetEntityNoCollisionEntity(two, one, true)

    dprint(("Disable collisions between entity %s and entity %s."):format(one,two))
end

---Used to set the alpha (opacity) of an entity
local function SetAlpha(entity, alpha)
    if entity == cache.ped then
        return
    end

    if alpha >= 255 then
        ResetEntityAlpha(entity)
    else
        SetEntityAlpha(entity, alpha, false)
    end

    dprint(("Alpha of entity %s set to %s."):format(alpha, entity))
end

---Triggered every time an entity leaves the zone
local function entityLeftTheZone(entity)
    stashedEntities[entity] = nil

    SetAlpha(entity, 255)
    dprint(("Entity left the zone %s"):format(entity))
end

---Triggered when the player enters the zone
---@param self any
function OnEnter(self)
    LocalPlayer.state.safezone = self.zoneName

    if self.zonetype.logJoinAndExit then
        insideZoneTime = 0

        CreateThread(function()
            while LocalPlayer.state.safezone do
                insideZoneTime += 1
                Wait(1000)
            end
        end)
    end

    if self.zonetype.kickIfAFK and (self.zonetype.kickIfAFK > 0) then
        local afkTime
        local prevPos

        CreateThread(function()
            while LocalPlayer.state.safezone do
                local currentPos = GetEntityCoords(cache.ped, true)

                if prevPos and currentPos == prevPos then
                    if afkTime > 0 then
                        if self.zonetype.notifyAFK then
                            for _, notifyTime in ipairs(Config.afkNotifyTimes) do
                                if afkTime == math.ceil(self.zonetype.kickIfAFK / notifyTime) then
                                    notify(("You are AFK, in %d you will be kicked by the server."):format(afkTime), "warning")
                                    break
                                end
                            end
                        end

                        afkTime = afkTime - 1
                    else
                        TriggerServerEvent("fanca_safezone:kick", self.zoneName)
                    end
                else
                    afkTime = self.zonetype.kickIfAFK
                end

                prevPos = currentPos

                Wait(1000)
            end
        end)
    end

    if self.zonetype.logJoinAndExit then
        TriggerServerEvent("fanca_safezone:log", self.zoneName, "enter")
    end

    if self.zonetype.notifyPlayer then
        notify("You entered a safe zone.", "success")
    end

    if self.zonetype.disableWeapon then
        NetworkSetFriendlyFireOption(false)
    end

    if cache.vehicle then
        if not self.zonetype.disableVehicle and self.zonetype.limitVehicleSpeed then
            SetVehicleMaxSpeed(cache.vehicle, self.zonetype.limitVehicleSpeed)
        end
    end

    if self.zonetype.disableCollision then
        if self.zonetype.disableCollision.peds then
            CreateThread(function()
                while LocalPlayer.state.safezone do
                    local peds = GetGamePool('CPed')

                    for i = 1, #peds do
                        local ped = peds[i]

                        if entityIsInZone(self, ped) then
                            if ped ~= cache.ped then
                                if not stashedEntities[ped] then
                                    stashedEntities[ped] = true
                                    SetAlpha(ped, Config.CollisionAlpha)

                                    dprint(("Stashed a new ped %s"):format(ped))
                                end
                            end
                        end
                    end

                    Wait(300)
                end
            end)
        end

        if self.zonetype.disableCollision.vehicles then
            CreateThread(function()
                while LocalPlayer.state.safezone do
                    local vehicles = GetGamePool('CVehicle')

                    for i = 1, #vehicles do
                        local vehicle = vehicles[i]

                        if entityIsInZone(self, vehicle) then
                            if not stashedEntities[vehicle] then
                                stashedEntities[vehicle] = true
                                SetAlpha(vehicle, Config.CollisionAlpha)

                                dprint(("Stashed a new vehicle %s"):format(vehicle))
                            end
                        end
                    end

                    Wait(300)
                end
            end)
        end

        CreateThread(function()
            while LocalPlayer.state.safezone do
                for entity,_ in pairs(stashedEntities) do
                    if not entityIsInZone(self, entity) then
                        entityLeftTheZone(entity)
                    end
                end

                Wait(500)
            end
        end)
    end
end

---Triggered when the player leaves the zone
---@param self any
function OnExit(self)
    LocalPlayer.state.safezone = nil

    if self.zonetype.logJoinAndExit then
        TriggerServerEvent("fanca_safezone:log", self.zoneName, "exit", insideZoneTime)
    end

    if self.zonetype.notifyPlayer then
        notify("You left the safe zone.", "success")
    end

    if self.zonetype.disableWeapon then
        NetworkSetFriendlyFireOption(true)
    end

    if cache.vehicle then
        if self.zonetype.disableVehicle and not GetIsVehicleEngineRunning(cache.vehicle) then
			SetVehicleEngineOn(cache.vehicle, true, true, true)
        elseif self.zonetype.limitVehicleSpeed then
            SetVehicleMaxSpeed(cache.vehicle, 99999.9)
        end
    end

    if self.zonetype.disableCollision then
        for entity,_ in pairs(stashedEntities) do
            entityLeftTheZone(entity)
        end
    end
end

---Triggered whenever the player is in the zone
---@param self any
function Inside(self)
    if self.zonetype.disablePlayerShoot then
        SetPlayerCanDoDriveBy(cache.ped, false)
        DisablePlayerFiring(cache.ped, true)
        DisableControlAction(0, 140, true)
    end

    if self.zonetype.disableWeapon then
        if GetCurrentPedWeapon(cache.ped, true) then
            TriggerEvent("ox_inventory:disarm", true)
            notify("You cannot hold a weapon in a safe zone.", "error")
        end
    end

    if cache.vehicle then
        if self.zonetype.disableVehicle then
            if GetIsVehicleEngineRunning(cache.vehicle) then
                SetVehicleEngineOn(cache.vehicle, false, true, true)
            end
        end
    end

    if self.zonetype.disableJump then
        DisableControlAction(0, 22, true)
    end

    if self.zonetype.disableCollision then
        for entity,_ in pairs(stashedEntities) do
            if cache.vehicle then
                DisableCollisionsThisFrame(cache.vehicle, entity)
            else
                DisableCollisionsThisFrame(cache.ped, entity)
            end
        end
    end
end

---Return the center point between the points
---@param points table<vector3>
---@return vector3
function getCenterPoint(points)
    local sumX, sumY, sumZ = 0, 0, 0

    for _, point in ipairs(points) do
        sumX = sumX + point.x
        sumY = sumY + point.y
        sumZ = sumZ + point.z
    end

    local numPoints = #points
    local centerX = sumX / numPoints
    local centerY = sumY / numPoints
    local centerZ = sumZ / numPoints

    return vec3(centerX, centerY, centerZ)
end

---Function that prints errors when debug functionality is active
---@param ... unknown
function dprint(...)
    if Config.debug then
        print(...)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (cache.resource ~= resourceName) then return end

    for entity,_ in pairs(stashedEntities) do
        entityLeftTheZone(entity)
    end
end)
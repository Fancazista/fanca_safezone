local GetEntityCoords = GetEntityCoords
local SetEntityNoCollisionEntity = SetEntityNoCollisionEntity
local SetEntityInvincible = SetEntityInvincible
local SetEntityCanBeDamaged = SetEntityCanBeDamaged
local SetEntityAlpha = SetEntityAlpha
local NetworkSetFriendlyFireOption = NetworkSetFriendlyFireOption
local SetVehicleMaxSpeed = SetVehicleMaxSpeed
local SetLocalPlayerAsGhost = SetLocalPlayerAsGhost
local SetPlayerCanDoDriveBy = SetPlayerCanDoDriveBy
local DisablePlayerFiring = DisablePlayerFiring
local DisableControlAction = DisableControlAction
local IsPedArmed = IsPedArmed

local insideZoneTime = 0
local stashedVehicles = {}
local stashedPeds = {}
local stashedPlayerPeds = {}

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GENERAL FUNCTIONS
---------------------------------------------------------------------------------------------------------------------------------------------------------------

---Return the center point between the points
---@param points table<vector3>
---@return vector3
function GetCenterPoint(points)
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
function dprint(...)
    if Config.debug then
        print(...)
    end
end

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
    end

    return (Config.Zones[self.zoneName].zone:contains(GetEntityCoords(entity)))
end

---Used to disable collisions between two entities
local function DisableCollisionsThisFrame(one, two)
    SetEntityNoCollisionEntity(one, two, true)
    SetEntityNoCollisionEntity(two, one, true)

    -- dprint(("Disable collisions between entity %s and entity %s."):format(one,two))
end

local function setVehicleCanCosmDamage(vehicle, state)
	SetVehicleCanBeVisiblyDamaged(vehicle, not state)
    SetVehicleReceivesRampDamage(vehicle, not state)
    SetVehicleHasUnbreakableLights(vehicle, state)
    SetVehicleTyresCanBurst(vehicle, not state)
    for i = 0, GetNumberOfVehicleDoors(vehicle) do
        SetVehicleDoorCanBreak(vehicle, i, not state)
    end
    SetDisableVehicleWindowCollisions(vehicle, state)
end

local function setVehicleCanMechDamage(vehicle, state)
    SetEntityProofs(vehicle, state, state, state, state, state, state, state, state)
	SetVehicleEngineCanDegrade(vehicle, not state)
	SetVehicleCanBreak(vehicle, not state)
	SetVehicleWheelsCanBreak(vehicle, not state)
	SetDisableVehiclePetrolTankDamage(vehicle, state)
    SetDisableVehiclePetrolTankFires(vehicle, state)
    SetDisableVehicleEngineFires(vehicle, state)
	SetVehicleStrong(vehicle, state)
    SetEntityCanBeDamaged(vehicle, state)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PED
---------------------------------------------------------------------------------------------------------------------------------------------------------------

---Handle stash of a new ped
local function stashPed(ped, pedOptions)
    stashedPeds[ped] = pedOptions

    if pedOptions then
        if pedOptions.makeInvincible then
            SetEntityInvincible(ped, true)
            SetEntityCanBeDamaged(ped, false)
        end

        if pedOptions.customAlpha then
            SetEntityAlpha(ped, pedOptions.customAlpha, false)
        end

        if pedOptions.disableEvents then
            TaskSetBlockingOfNonTemporaryEvents(ped, true)
        end

        if pedOptions.SetFootstepQuiet then
            SetPedAudioFootstepLoud(ped, false)
        end
    end

    dprint(("Stashed a new ped %s"):format(ped))
end

---Handle unstash of a ped
local function unstashPed(ped, pedOptions)
    stashedPeds[ped] = nil

    if pedOptions then
        if pedOptions.makeInvincible then
            SetEntityInvincible(ped, true)
            SetEntityCanBeDamaged(ped, false)
        end

        if pedOptions.customAlpha then
            ResetEntityAlpha(ped)
        end

        if pedOptions.disableEvents then
            TaskSetBlockingOfNonTemporaryEvents(ped, false)
        end

        if pedOptions.SetFootstepQuiet then
            SetPedAudioFootstepLoud(ped, true)
        end
    end

    dprint(("Unstashed the ped %s"):format(ped))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYER PEDS
---------------------------------------------------------------------------------------------------------------------------------------------------------------

---Handle stash of a new player ped
local function stashPlayerPed(ped, pedOptions)
    stashedPlayerPeds[ped] = pedOptions

    if pedOptions then
        if pedOptions.SetFootstepQuiet then
            SetPedAudioFootstepLoud(ped, false)
        end
    end

    dprint(("Stashed a new player ped %s"):format(ped))
end

---Handle unstash of a player ped
local function unstashPlayerPed(ped, pedOptions)
    stashedPlayerPeds[ped] = nil

    if pedOptions then
        if pedOptions.SetFootstepQuiet then
            SetPedAudioFootstepLoud(ped, true)
        end
    end

    dprint(("Unstashed the player ped %s"):format(ped))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEHICLE
---------------------------------------------------------------------------------------------------------------------------------------------------------------

---Handle stash of a new vehicle
local function stashVehicle(vehicle, vehicleOptions)
    stashedVehicles[vehicle] = vehicleOptions

    if vehicleOptions then
        if vehicleOptions.makeInvincible then
            setVehicleCanCosmDamage(vehicle, true)
            setVehicleCanMechDamage(vehicle, true)
            SetEntityInvincible(vehicle, true)
        end

        if vehicleOptions.customAlpha then
            SetEntityAlpha(vehicle, vehicleOptions.customAlpha, false)
        end

        if vehicleOptions.autoVehicleLock then
            SetVehicleDoorsLocked(vehicle, 2)
        end

        if vehicleOptions.disableVehicle then
            SetVehicleUndriveable(vehicle, true)
        elseif vehicleOptions.limitVehicleSpeed then
            SetVehicleMaxSpeed(vehicle, vehicleOptions.limitVehicleSpeed)
        end
    end

    dprint(("Stashed a new vehicle %s"):format(vehicle))
end

---Handle unstash of a vehicle
local function unstashVehicle(vehicle, vehicleOptions)
    stashedVehicles[vehicle] = nil

    if vehicleOptions then
        if vehicleOptions.makeInvincible then
            setVehicleCanCosmDamage(vehicle, false)
            setVehicleCanMechDamage(vehicle, false)
            SetEntityInvincible(vehicle, false)
        end

        if vehicleOptions.customAlpha then
            ResetEntityAlpha(vehicle)
        end

        if vehicleOptions.autoVehicleLock then
            SetVehicleDoorsLocked(vehicle, 1)
        end

        if vehicleOptions.disableVehicle then
            SetVehicleUndriveable(vehicle, false)
        elseif vehicleOptions.limitVehicleSpeed then
            SetVehicleMaxSpeed(vehicle, 99999.9)
        end
    end

    dprint(("Unstashed the vehicle %s"):format(vehicle))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONES
---------------------------------------------------------------------------------------------------------------------------------------------------------------

---Triggered when the player enters the zone
function OnEnter(self)
    LocalPlayer.state.safezone = self.zoneName

    if self.zonetype.logJoinAndExit then
        TriggerServerEvent("fanca_safezone:log", self.zoneName, "enter")

        insideZoneTime = 0
        CreateThread(function()
            while LocalPlayer.state.safezone do
                insideZoneTime += 1
                Wait(1000)
            end
        end)
    end

    -- Players configurations
    if self.zonetype.player then
        if self.zonetype.player.areaNotify then
            notify("You entered a safe zone.", "success")
        end

        if (self.zonetype.player.kickAFK) and (self.zonetype.player.kickAFK > 0) then
            CreateThread(function()
                local afkTime
                local prevPos

                while LocalPlayer.state.safezone do
                    local currentPos = GetEntityCoords(cache.ped, true)

                    if prevPos and currentPos == prevPos then
                        if afkTime > 0 then
                            if self.zonetype.player.kickNotify then
                                for _, notifyTime in ipairs(Config.afkNotifyTimes) do
                                    if afkTime == math.ceil(self.zonetype.player.kickAFK / notifyTime) then
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
                        afkTime = self.zonetype.player.kickAFK
                    end

                    prevPos = currentPos

                    Wait(1000)
                end
            end)
        end

        if self.zonetype.player.disableShoot then
            NetworkSetFriendlyFireOption(false)
        end

        if self.zonetype.player.disableDriveBy then
            SetPlayerCanDoDriveBy(cache.playerId, false)
        end

        if self.zonetype.player.disableIdleCam then
            DisableIdleCamera(true)
        end

        if self.zonetype.player.SetFootstepQuiet then
            SetPedAudioFootstepLoud(cache.ped, false)
        end

        if self.zonetype.player.ghostMode then
            SetLocalPlayerAsGhost(true)
        end
    end

    -- Peds configurations
    if self.zonetype.ped then
        CreateThread(function()
            while LocalPlayer.state.safezone do
                CreateThread(function()
                    local peds = GetGamePool('CPed')

                    for i = 1, #peds do
                        local ped = peds[i]

                        if entityIsInZone(self, ped) then
                            if self.zonetype.ped.playerPeds and IsPedAPlayer(ped) and not stashedPlayerPeds[ped] and ped ~= cache.ped then
                                stashPlayerPed(ped, self.zonetype.ped.playerPeds)
                            elseif not IsPedAPlayer(ped) and not stashedPeds[ped] then
                                stashPed(ped, self.zonetype.ped)
                            end
                        end
                    end
                end)

                Wait(self.zonetype.ped.newEntitiesRefreshRate or 1000)
            end
        end)

        CreateThread(function()
            while LocalPlayer.state.safezone do
                for ped,pedOptions in pairs(stashedPeds) do
                    if not entityIsInZone(self, ped) then
                        unstashPed(ped, pedOptions)
                    end
                end

                for ped,pedOptions in pairs(stashedPlayerPeds) do
                    if not entityIsInZone(self, ped) then
                        unstashPlayerPed(ped, pedOptions)
                    end
                end

                Wait(self.zonetype.ped.newEntitiesRefreshRate or 1000)
            end
        end)

        if self.zonetype.ped?.disableCollisions then
            CreateThread(function()
                while LocalPlayer.state.safezone do
                    if next(stashedPeds) then
                        for ped,_ in pairs(stashedPeds) do
                            if cache.vehicle then
                                DisableCollisionsThisFrame(cache.vehicle, ped)
                            else
                                DisableCollisionsThisFrame(cache.ped, ped)
                            end

                            SetPedMoveRateOverride(ped, self.zonetype.ped.setPedMoveRate)
                        end

                        Wait(1)
                    else
                        Wait(500)
                    end
                end
            end)
        end
    end

    -- Vehicle configurations
    if self.zonetype.vehicle then
        CreateThread(function()
            while LocalPlayer.state.safezone do
                CreateThread(function()
                    local vehicles = GetGamePool('CVehicle')

                    for i = 1, #vehicles do
                        local vehicle = vehicles[i]

                        if entityIsInZone(self, vehicle) then
                            if not stashedVehicles[vehicle] then
                                stashVehicle(vehicle, self.zonetype.vehicle)
                            end
                        end
                    end
                end)

                Wait(self.zonetype.vehicle.newEntitiesRefreshRate or 1000)
            end
        end)

        CreateThread(function()
            while LocalPlayer.state.safezone do
                for vehicle,vehicleOptions in pairs(stashedVehicles) do
                    if not entityIsInZone(self, vehicle) then
                        unstashVehicle(vehicle, vehicleOptions)
                    end
                end

                Wait(self.zonetype.vehicle.newEntitiesRefreshRate or 1000)
            end
        end)

        if self.zonetype.vehicle.disableCollisions then
            CreateThread(function()
                while LocalPlayer.state.safezone do
                    if next(stashedVehicles) then
                        for vehicle,_ in pairs(stashedVehicles) do
                            if cache.vehicle then
                                DisableCollisionsThisFrame(cache.vehicle, vehicle)
                            else
                                DisableCollisionsThisFrame(cache.ped, vehicle)
                            end
                        end
                        Wait(1)

                    else
                        Wait(500)
                    end

                end
            end)
        end
    end
end

---Triggered when the player leaves the zone
function OnExit(self)
    LocalPlayer.state.safezone = nil

    if self.zonetype.logJoinAndExit then
        TriggerServerEvent("fanca_safezone:log", self.zoneName, "exit", insideZoneTime)
    end

    -- Players configurations
    if self.zonetype.player then
        if self.zonetype.player.areaNotify then
            notify("You left the safe zone.", "success")
        end

        if self.zonetype.player.disableShoot then
            NetworkSetFriendlyFireOption(true)
        end

        if self.zonetype.player.disableDriveBy then
            SetPlayerCanDoDriveBy(cache.playerId, true)
        end

        if self.zonetype.player.disableIdleCam then
            DisableIdleCamera(false)
        end

        if self.zonetype.player.SetFootstepQuiet then
            SetPedAudioFootstepLoud(cache.ped, true)
        end

        if self.zonetype.player.ghostMode then
            SetLocalPlayerAsGhost(false)
        end
    end

    -- Peds configurations
    if self.zonetype.ped then
        for ped,pedOptions in pairs(stashedPeds) do
            unstashPed(ped, pedOptions)
        end

        -- Other player peds configurations
        if self.zonetype.ped.playerPeds then
            for ped,pedOptions in pairs(stashedPlayerPeds) do
                unstashPlayerPed(ped, pedOptions)
            end
        end
    end

    -- Vehicle configurations
    if self.zonetype.vehicle then
        for vehicle,vehicleOptions in pairs(stashedVehicles) do
            unstashVehicle(vehicle, vehicleOptions)
        end
    end
end

---Triggered whenever the player is in the zone
function Inside(self) -- is triggered in a loop with a wait(0)
    if self.zonetype.player then
        if self.zonetype.player.disableShoot then
            DisablePlayerFiring(cache.ped, true)
            DisableControlAction(0, 140, true)
        end

        if self.zonetype.player.disableWeapons then
            if IsPedArmed(cache.ped, 4 | 2 | 1) then
                Config.disarmPlayer()
                notify("You cannot hold a weapon in a safe zone.", "error")
            end
        end

        if self.zonetype.player.disableJump then
            DisableControlAction(0, 22, true)
        end

        if self.zonetype.player.setPedMoveRate then
            SetPedMoveRateOverride(cache.ped, self.zonetype.player.setPedMoveRate)
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (cache.resource ~= resourceName) then return end

    -- Peds configurations
    for ped,pedOptions in pairs(stashedPeds) do
        unstashPed(ped, pedOptions)
    end

    -- Other player peds configurations
    for ped,pedOptions in pairs(stashedPlayerPeds) do
        unstashPlayerPed(ped, pedOptions)
    end

    -- Vehicle configurations
    for vehicle,vehicleOptions in pairs(stashedVehicles) do
        unstashVehicle(vehicle, vehicleOptions)
    end
end)

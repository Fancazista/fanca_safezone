local kmh = 3.6
local mph = 2.236936

---------------------------------------------------------------------------------------------------------------------------------------------------------------

Config = {}

Config.debug = false --- Enable debugging messages

Config.ghostedEntitiesAlpha = 100

Config.afkDropMessage = "You got kicked from the server for: AFK in safe zone." --- Message sent when player is disconnected because AFK
Config.afkNotifyTimes = {2, 3, 6, 10}

---Function triggered when the player holds a weapon and he must be disarmed
Config.disarmPlayer = function()
    -- Uncomment the system you want to use. If you use the ox inventory uncomment the event, otherwise uncomment the GTA default system.

    -- TriggerEvent("ox_inventory:disarm", true) -- ox_inventory
    SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true) -- default system
end

---Zones types
Config.Types = {
    ['test1'] = {
        logJoinAndExit = true,

        -- Players configurations
        player = {
            areaNotify = true,

            kickAFK = 600,
            kickNotify = true,

            disableShoot = true,
            disableDriveBy = true,
            disableWeapons = true,
            disableJump = true,
            disableIdleCam = true,

            SetFootstepQuiet = true,
            setPedMoveRate = 2.0,

            ghostMode = true, -- disable collision between other players (ped and car)
        },

        -- Peds (NPC) configurations
        ped = {
            newEntitiesRefreshRate = 250,

            disableCollisions = true, -- disable collision between npcs
            makeInvincible = true,
            customAlpha = 100,
            disableEvents = true,

            SetFootstepQuiet = true,
            setPedMoveRate = 2.0,

            -- Other player peds configurations
            playerPeds = {
                SetFootstepQuiet = true,
            },
        },

        -- Vehicle configurations
        vehicle = {
            newEntitiesRefreshRate = 250,
            disableCollisions = true, -- disable collision between vehicles
            makeInvincible = true,
            customAlpha = 200,
            autoVehicleLock = true,
            disableVehicle = true,
            limitVehicleSpeed = 50 / kmh,
        },
    },

    ['test2'] = {
        logJoinAndExit = true,

        player = {
            areaNotify = true,
            disableWeapons = true,
            disableIdleCam = true,
            ghostMode = true, -- disable collision between other players (ped and car)
        },

        ped = {
            newEntitiesRefreshRate = 250,
            makeInvincible = true,
            disableEvents = true,
        },
    }
}

---Locations of the zones
Config.Zones = {
    ['Central garage'] = {
        type = "test1",
        debug = false,

        blip = {
            label = "Safe zone",
            display = 2,
            id = 461,
            color = 66,
            scale = 0.8,
        },

        poly = {
            points = {
                vec3(229.0, -723.25, 33.25),
                vec3(199.35000610352, -806.0, 33.25),
                vec3(244.0, -823.0, 33.25),
                vec3(275.95001220703, -739.79998779297, 33.25),
            },
            thickness = 23.8,
        }

        -- box = {
        --     coords = vec3(238.0, -773.0, 35.0),
        --     size = vec3(89, 50.0, 25.0),
        --     rotation = 70.0,
        -- }

        -- sphere = {
        --     coords = vec3(227.6967010498, -788.95385742188, 30.678344726562),
        --     radius = 25,
        -- }

        -- point = {
        --     coords = vec3(227.6967010498, -788.95385742188, 30.678344726562),
        --     distance = 15.0,
        -- }
    },

    ['Central square'] = {
        type = "test2",
        debug = false,

        blip = {
            label = "Safe zone",
            display = 2,
            id = 461,
            color = 66,
            scale = 0.8,
        },

        poly = {
            points = {
                vec3(262.0, -872.0, 29.0),
                vec3(185.0, -844.0, 29.0),
                vec3(132.0, -988.0, 29.0),
                vec3(210.60000610352, -1015.5, 29.0),
            },
            thickness = 20.0,
        }
    },
}
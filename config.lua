local kmh = 3.6
local mph = 2.236936

Config = {}

Config.debug = false

Config.CollisionAlpha = 110

Config.afkDropMessage = "You got kicked from the server for: AFK in safe zone."
Config.afkNotifyTimes = {2, 3, 6, 10}

Config.disarmPlayer = function()
    -- Uncomment the system you want to use. If you use the ox inventory uncomment the event, otherwise uncomment the GTA default system.

    TriggerEvent("ox_inventory:disarm", true) -- ox_inventory
    -- SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true) -- default system
end

Config.Types = {
    ['test1'] = {
        logJoinAndExit = true,
        notifyPlayer = true,
        disablePlayerShoot = true,
        disableWeapon = true,
        disableVehicle = false,
        limitVehicleSpeed = 0 / kmh,
        disableJump = true,
        disableCollision = {
            peds = true,
            vehicles = true
        },
        notifyAFK = false,
        kickIfAFK = 0,
    }
}

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
    }
}
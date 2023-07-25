local kmh = 3.6
local mph = 2.236936

Config = {}

Config.debug = false

Config.CollisionAlpha = 110

Config.afkDropMessage = "You got kicked from the server for: AFK in safe zone."
Config.afkNotifyTimes = {2, 3, 6, 10}

Config.Types = {
    ['test1'] = {
        logJoinAndExit = true,
        notifyPlayer = true,
        disablePlayerShoot = true,
        disableWeapon = true,
        disableVehicle = false,
        limitVehicleSpeed = 50 / kmh,
        disableJump = true,
        disableCollision = {
            peds = true,
            vehicles = true
        },
        notifyAFK = true,
        kickIfAFK = 180,
    },

    ['test2'] = {
        logJoinAndExit = true,
        notifyPlayer = true,
        disablePlayerShoot = false,
        disableWeapon = true,
        disableVehicle = false,
        limitVehicleSpeed = 0 / kmh,
        disableJump = false,
        disableCollision = {
            peds = false,
            vehicles = false
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
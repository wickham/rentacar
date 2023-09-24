ESX = nil
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

Config = {}
Config.Time = 300 -- car rental time example 2 minutes
Config.PlateText = 'RENT ' -- rented car plate number (max 8 characters) e.g. RENT 000
Config.MarkerName = ""
Config.CleanupRadius = 2
Config.EnableInspect = true
Config.Locations = {
    ["Touchdown Rentals"] = {
        --     {
        --     coords = vector3(237.3967, -763.023, 29.824),
        --     hash = "a_m_o_soucent_01",
        --     heading = 170.00,
        --     marker = "Rent",
        --     vehicle = vector4(235.8658, -782.916, 30.645, 179.64),
        --     location = {
        --         posX = 233.37,
        --         posY = -789.9,
        --         posZ = 30.6,
        --         rotX = 0.0,
        --         rotY = 0.0,
        --         rotZ = -22.0,
        --         fov = 50.0
        --     },
        --     spawn = vector3(229.3833, -800.980, 30.037)
        -- }
        coords = vector3(-833.3300170898438, -2348.409912109375, 13.58),
        hash = "a_m_y_business_02",
        scenario = "WORLD_HUMAN_CLIPBOARD",
        heading = 270.2,
        label = "Touchdown Rentals",
        vehicle = vector4(-833.8499755859375, -2335.4599609375, 14.13000011444091, 26.8),
        location = {
            posX = -834.14,
            posY = -2328.82,
            posZ = 14.569,
            rotX = 0.0,
            rotY = 0.0,
            rotZ = 183.117,
            fov = 50.0
        },
        spawns = {
            -- Section M
            [1] = vector4(-823.8599853515625, -2343.030029296875, 14.02000045776367, 149.7893829345703),
            [2] = vector4(-821.0399780273438, -2344.929931640625, 14.17000007629394, 149.01820373535156),
            [3] = vector4(-817.9400024414062, -2346.389892578125, 14.02000045776367, 149.66976928710938),
            [4] = vector4(-814.989990234375, -2348.27001953125, 14.15999984741211, 149.1281280517578),
            -- Section L
            [5] = vector4(-811.7999877929688, -2349.659912109375, 14.02000045776367, 149.87518310546875),
            [6] = vector4(-808.9000244140625, -2351.419921875, 14.15999984741211, 149.87022399902344),
            [7] = vector4(-806.0399780273438, -2353.47998046875, 14.02000045776367, 149.88755798339844),
            [8] = vector4(-803.010009765625, -2355.0400390625, 14.15999984741211, 149.7062530517578),
            -- [9] = vector4(-811.0999755859375, -2338.3798828125, 14.0600004196167, 234.15988159179688)
            -- Section J
            [9] = vector4(-808.8900146484375, -2367.760009765625, 13.85999965667724, 330.019775390625),
            [10] = vector4(-811.9000244140625, -2366.050048828125, 13.85999965667724, 329.6617126464844),
            [11] = vector4(-814.9600219726562, -2364.389892578125, 13.85999965667724, 329.7321472167969),
            [12] = vector4(-818.1099853515625, -2363.070068359375, 13.85999965667724, 330.2351684570313),
            -- Section K
            [13] = vector4(-820.8200073242188, -2360.800048828125, 13.85999965667724, 330.033447265625),
            [14] = vector4(-823.9400024414062, -2359.43994140625, 13.85999965667724, 330.1116027832031),
            [15] = vector4(-826.8200073242188, -2357.6201171875, 13.85999965667724, 330.1493835449219),
            [16] = vector4(-829.9600219726562, -2355.93994140625, 13.85999965667724, 329.88916015625)
        },
        inspect_function = function()
            exports["inspect"]:AddBoxZone("Touchdown Rentals",
                vector3(-833.3300170898438, -2348.409912109375, 13.58 + 1.0), 1.0, 1.0, {
                    name = "Touchdown Rentals",
                    heading = 270.2,
                    debugPoly = false,
                    minZ = 13.58 - 0.0,
                    maxZ = 13.58 + 2.5
                }, {
                    options = {{
                        event = 'rentacar:showAll',
                        args = {
                            car_preview = vector4(-833.8499755859375, -2335.4599609375, 14.13000011444091, 26.8),
                            camera = {
                                posX = -834.14,
                                posY = -2328.82,
                                posZ = 14.569,
                                rotX = 0.0,
                                rotY = 0.0,
                                rotZ = 183.117,
                                fov = 50.0
                            },
                            car_spawns = {
                                [1] = vector4(-823.8599853515625, -2343.030029296875, 14.02000045776367,
                                    149.7893829345703)

                            }
                        },
                        icon = 'fa-solid fa-comments',
                        label = "Whatcha Got?"
                    }},
                    distance = 2.5
                })
        end
    }
}

Config.GetVehFuel = function(Veh)
    return GetVehicleFuelLevel(Veh) -- exports["LegacyFuel"]:GetFuel(Veh)
end

Config.Vehicles = {{
    model = "faggio2",
    label = "FAGGIO",
    price = 1000,
    icon = "motorcycle",
    stock = 50
}, {
    model = "oracle2",
    label = "ORACLE",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "Jackal",
    label = "JACKAL",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "zion2",
    label = "ZION CABRIO",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "dominator",
    label = "DOMINATOR",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "schafter2",
    label = "SCHAFTER",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "dubsta",
    label = "DUBSTA",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "raiden",
    label = "RAIDEN",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "ellie",
    label = "ELLIE",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "drafter",
    label = "8F DRAFTER",
    price = 1000,
    icon = "car-side",
    stock = 1
}, {
    model = "jugular",
    label = "JUGULAR",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "baller2",
    label = "BALLER LS",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "stretch",
    label = "STRETCH",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "rapidgt2",
    label = "RAPID GT CONV",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "surge",
    label = "SURGE",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "serrano",
    label = "SERRANO",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "speedo",
    label = "SPEEDO",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "bison",
    label = "BISON",
    price = 1000,
    icon = "truck-pickup",
    stock = 10
}, {
    model = "zentorno",
    label = "ZENTORNO",
    price = 1000,
    icon = "car-side",
    stock = 0
}, {
    model = "mamba",
    label = "MAMBA",
    price = 1000,
    icon = "car-side",
    stock = 10
}, {
    model = "xls",
    label = "XLS",
    price = 1000,
    icon = "van-shuttle",
    stock = 10
}, {
    model = "neon",
    label = "NEON",
    price = 1000,
    icon = "car-side",
    stock = 10
}}
RENTACAR = {}
RENTACAR.Functions = {
    CreateInspect = function()
        if Config.EnableInspect then
            for _, v in pairs(Config.Locations) do
                v.inspect_function()
            end
        end
    end
}


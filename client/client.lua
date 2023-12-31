ESX = nil
TriggerEvent("esx:getSharedObject", function(obj)
    ESX = obj
end)

local server_vehicles = {}

local starter = false
local player_papers = {}
local vehicle = nil
local inMenu = false
local spawns = {}
local time = 0
local location = {}
local veh_stocks = {}

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end
    lib.hideContext()
    -- Cleanup and lingering vehicles in spawn and preview locations
    TriggerEvent("rentacar:cleanupAreas")
    refreshStock()
    -- hasPapers("RENT 001")

end)

AddEventHandler('esx:onPlayerSpawn', function()
    -- Cleanup menus if they were left open on restart
    lib.hideContext()
    -- Cleanup and lingering vehicles in spawn and preview locations
    TriggerEvent("rentacar:cleanupAreas")
    refreshStock()

end)

AddEventHandler("rentacar:rentVehicle", function(args)
    SendNUIMessage({
        type = "ui",
        data = false
    })
    SetNuiFocus(false, false)
    TriggerEvent("rentacar:retalSelected")

    local data = args.data
    local parking = args.spawns
    ESX.TriggerServerCallback("isPrice", function(istrue)
        if istrue == true then
            SpawnVehicle(data.model, function(car)

                SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(car), PlayerPedId(), true)
                SetEntityAsMissionEntity(car, true, true)
                SetVehicleEngineOn(car, false, false, true)

                toggleNoCollision(car, true)
                makeVehicleSafe(car, nil)

                ESX.TriggerServerCallback("createRenterPlate", function(rental_plate)
                    -- Set Plate Name
                    TriggerServerEvent("rentacar:deleteInventory", rental_plate, data.model)
                    SetVehicleNumberPlateText(car, rental_plate)
                    -- GIVE KEYS
                    local name = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(car)))
                    local primary, secondary = GetVehicleColours(car)
                    local color = __VEHICLE_COLORS__[primary]

                    exports["keys"]:GiveTemporaryKeys(PlayerId(), exports['cd_garage']:GetPlate(car), name, "rental")

                    -- Store info in server
                    TriggerServerEvent("rentacar:setClientRentals", -1, rental_plate,
                        data.model:gsub("^%l", string.upper), color, rental_plate)
                    -- TODO: Delete Current plate inventory
                    TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(car))
                    SetVehicleFuelLevel(car, 100.0)
                    TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)

                    DisplayRadar(true)
                    DisplayHud(true)
                    -- ADD RENTAL PAPER LOGIC HERE
                    TriggerServerEvent("inventory:registerVehicleInventory", exports['cd_garage']:GetPlate(car))

                    PutPapersInGlovebox(exports['cd_garage']:GetPlate(car), {
                        color = color,
                        model = data.model:gsub("^%l", string.upper)
                    })
                    refreshStock()
                    TriggerEvent("swt_notifications:captionIcon", "", "Papers are in the glove box!", "top", 4000,
                        "positive", "white", true, "mdi-clipboard-check-multiple")
                end)
            end, parking, true)
        elseif istrue == "broke" then
            TriggerEvent("swt_notifications:captionIcon", "", "Not Enough Cash", "top", 4000, "negative", "white", true,
                "mdi-currency-usd-off")
        elseif istrue == "no_stock" then
            TriggerEvent("swt_notifications:captionIcon", "Out of Stock", "", "top", 4000, "grey", "white", true,
                "mdi-cart-off")
        elseif istrue == "no_vehicle" then
            TriggerEvent("swt_notifications:captionIcon", "No Vehicle", "", "top", 4000, "grey", "white", true,
                "mdi-error")
        elseif istrue == "max_rentals" then
            TriggerEvent("swt_notifications:captionIcon", "Return an old rental or pay the return fee!",
                "Rental Limit Exceeded!", "top", 10000, "grey", "white", true, "mdi-chat-alert")
        else
            TriggerEvent("swt_notifications:captionIcon", "", "Not Enough Cash", "top", 4000, "negative", "white", true,
                "mdi-currency-usd-off")
        end
    end, (data.price + data.deposit), data.model)

end)

RegisterNetEvent("rentacar:TDrentalMenu", function(source)
    callMainMenuUI("Touchdown Rentals")
    -- callRentalMenuUI()
end)

AddEventHandler("rentacar:cleanupPreviewArea", function()
    local radius = Config.CleanupRadius or 5
    if radius and tonumber(radius) then
        for _, v in pairs(Config.Locations) do
            local vehicles = ESX.Game.GetVehiclesInArea(v.vehicle, radius)
            for k, entity in ipairs(vehicles) do
                local attempt = 0

                while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
                    Citizen.Wait(100)
                    NetworkRequestControlOfEntity(entity)
                    attempt = attempt + 1
                end

                if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                    -- TriggerEvent("nocollision:turnOnCollision", entity)
                    ESX.Game.DeleteVehicle(entity)
                end
            end
        end
    end
end)

AddEventHandler("rentacar:cleanupAreas", function()
    local radius = Config.CleanupRadius or 5
    if radius and tonumber(radius) then
        for _, v in pairs(Config.Locations) do
            local vehicles = ESX.Game.GetVehiclesInArea(v.vehicle, radius)
            for k, entity in ipairs(vehicles) do
                local attempt = 0

                while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
                    Citizen.Wait(100)
                    NetworkRequestControlOfEntity(entity)
                    attempt = attempt + 1
                end

                if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                    ESX.Game.DeleteVehicle(entity)
                end
            end
        end
        for _, v in pairs(Config.Locations) do
            for _, location in pairs(v.spawns) do
                local vehicles = ESX.Game.GetVehiclesInArea(location, radius)
                for k, entity in ipairs(vehicles) do
                    local attempt = 0

                    while not NetworkHasControlOfEntity(entity) and attempt < 100 and DoesEntityExist(entity) do
                        Citizen.Wait(100)
                        NetworkRequestControlOfEntity(entity)
                        attempt = attempt + 1
                    end

                    if DoesEntityExist(entity) and NetworkHasControlOfEntity(entity) then
                        ESX.Game.DeleteVehicle(entity)
                    end
                end
            end
        end
    end
end)

AddEventHandler("rentacar:viewVehicle", function(this_location, cb)
    local model = GetHashKey(this_location.vehicle.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(7)
    end
    currentVeh = CreateVehicle(model, vehicle.x, vehicle.y, vehicle.z, vehicle.w, false, true)
    ESX.TriggerServerCallback("getRentalCount", function(rental_count)
        SetVehicleNumberPlateText(currentVeh, Config.PlateText .. string.format("%03d", rental_count % 1000))
    end)
    SetVehicleEngineOn(currentVeh, true, true, false)
    Camera()
    cb({
        fuel = Config.GetVehFuel(currentVeh),
        speed = GetVehicleEstimatedMaxSpeed(currentVeh),
        traction = GetVehicleMaxTraction(currentVeh),
        acceleration = GetVehicleAcceleration(currentVeh)
    })

end)

AddEventHandler("rentacar:TDshowAll", function(data)
    vehicle = data.args.car_preview
    location = data.args.camera
    spawns = data.args.car_spawns
    DisplayRadar(false)
    DisplayHud(false)
    TriggerEvent("rentacar:TDrentalMenu")
end)

AddEventHandler("rentacar:previewRentalView", function(data)
    -- Send data to UI
    -- Spawn vehicle based on data
    -- Move camera
    -- Render new Menu previewRentalView
    local calculated_data = spawnAndCalculateData(data)
    SendNUIMessage({
        type = "update",
        data = calculated_data
    })
    previewRentalView(calculated_data)

end)
AddEventHandler("rentacar:retalSelected", function(data)
    SetDisplay(false)
    DoScreenFadeOut(200)
    Citizen.Wait(200)
    DestroyAllCams(true)
    RenderScriptCams(false, false, 1700, true, false, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    EYESDeleteVehicle(currentVeh)
    DoScreenFadeIn(200)
    DisplayRadar(true)
    DisplayHud(true)

end)

AddEventHandler("rentacar:exit", function(data)
    SetDisplay(false)
    DestroyAllCams(true)
    RenderScriptCams(false, true, 1700, true, false, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    EYESDeleteVehicle(currentVeh)
    DisplayRadar(true)
    DisplayHud(true)

end)
AddEventHandler("rentacar:outOfStock", function(data)
    TriggerEvent("swt_notifications:captionIcon", "Out of Stock", "", "top", 4000, "grey", "white", true, "mdi-cart-off")

end)

AddEventHandler("rentacar:exitPreview", function(data)
    SendNUIMessage({
        type = "ui",
        data = false
    })
    -- TriggerEvent("rentacar:TDrentalMenu")
    SetDisplay(false)
    DestroyAllCams(true)
    RenderScriptCams(false, true, 1700, true, false, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    EYESDeleteVehicle(currentVeh)
    DisplayRadar(true)
    DisplayHud(true)
end)

function rent(vehicle)
    time = Config.Time
    if time ~= false then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1)
                if time ~= 0 then
                    Citizen.Wait(1000)
                    time = time - 1
                else
                    -- SetVehicleUndriveable(vehicle, true)
                    TriggerEvent("swt_notifications:captionIcon", "", "Rental Expired!", "top", 4000, "negative",
                        "white", true, "mdi-timer-alert")
                    TaskLeaveVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 4160)
                    SetVehicleDoorsLocked(vehicle, 6)
                    SetVehicleDoorsLocked(vehicle, 2)
                    Citizen.Wait(2500)
                    SetVehicleEngineHealth(vehicle, 0)
                    SetVehiclePetrolTankHealth(vehicle, 2)
                    SetVehicleOilLevel(vehicle, 1)
                    SetVehicleBodyHealth(vehicle, 2)
                    exports["legacyfuelredux"]:SetFuel(vehicle, 0.1)

                    -- DeleteEntity(vehicle)
                    break
                end
            end
        end)
        Citizen.CreateThread(function()
            while time > 0 do
                Citizen.Wait(0)
                SetTextFont(4)
                SetTextScale(0.45, 0.45)
                SetTextColour(185, 185, 185, 255)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                BeginTextCommandDisplayText('STRING')
                AddTextComponentSubstringPlayerName(" ~g~ - CAR RENTAL DURATION:" .. second(time))
                EndTextCommandDisplayText(0.05, 0.55)
            end
        end)
    end
end

function ELoadModel(model)
    if HasModelLoaded(model) then
        return
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

function SpawnVehicle(model, cb, spawns, isnetworked, teleportInto)
    local ped = PlayerPedId()
    model = type(model) == "string" and GetHashKey(model) or model
    if not IsModelInCdimage(model) then
        return
    end

    if type(spawns) ~= "table" then
        spawns = GetEntityCoords(ped)
    end
    isnetworked = isnetworked or true
    ELoadModel(model)
    local coords = nil
    local is_safe = nil
    coords, is_safe = getAvailableSpawn(spawns)

    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    rent(veh)
    local cars = ESX.Game.GetVehiclesInArea(coords, 1.0)
    clientDebugPrint(cars)
    for _, v in pairs(cars) do
        clientDebugPrint(_, v)
    end

    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end
    if is_safe then
        clientDebugPrint("SAFE FOR SPAWN")
    else
        clientDebugPrint("NOT SAFE!")

    end

    if cb then
        cb(veh)
    end
end

RegisterNUICallback("rotateright", function(data)
    SetEntityHeading(currentVeh, GetEntityHeading(currentVeh) - 2)
end)

RegisterNUICallback("rotateleft", function()
    SetEntityHeading(currentVeh, GetEntityHeading(currentVeh) + 2)
end)

function EYESDeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function Camera()
    local cam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", location.posX, location.posY, location.posZ,
        location.rotX, location.rotY, location.rotZ, location.fov, false, 2)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 2000, true, false, false)
    SetFocusPosAndVel(location.posX, location.posY, location.posZ, 0.0, 0.0, 0.0)
end

local display = false

RegisterNUICallback("exit", function(data)
    SetDisplay(false)
    DestroyAllCams(true)
    RenderScriptCams(false, true, 1700, true, false, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    EYESDeleteVehicle(currentVeh)
    DisplayRadar(true)
    DisplayHud(true)
end)

RegisterNUICallback("Delete", function()
    EYESDeleteVehicle(currentVeh)
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
end

Citizen.CreateThread(function()
    -- EYES.Functions.CreateBlips()
    RENTACAR.Functions.CreateInspect()
    for _, v in pairs(Config.Locations) do
        RequestModel(v.hash)
        while not HasModelLoaded(v.hash) do
            Wait(1)
        end
        x = v.coords[1]
        y = v.coords[2]
        z = v.coords[3]
        ped = CreatePed(4, v.hash, x, y, z, v.hash, 3374176, false, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", -1, true)
        SetEntityHeading(ped, v.heading)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
    end
end)

PutPapersInGlovebox = function(plate, data)
    clientDebugPrint(data)
    clientDebugPrint(data.model)
    clientDebugPrint(data.color)
    local glove_id = "glovebox_" .. plate
    TriggerServerEvent("GloveboxPapers", glove_id, "document_vehicle_rental", 1, 100.0, {
        plate = plate,
        vin = plate,
        model = data.model or "?",
        color = data.color or "?"
    })
end

function getNearbyRentals()
    -- get current rentals from server
    -- iter through and check if owner and car nearby, add to list
    -- return list
    ---RULES---
    -- 1) Rental vehicle is nearby (based radius from rental spot) -- plate will read "RENT XXX" (config) --> check our server list if it is out
    -- 2) Check if user has the vehicle rental (rental papers in inventory)
    local nearby_rentals = {}
    local vehList = GetGamePool('CVehicle')
    local ped = PlayerPedId()
    local vehicle_count = 0
    for item, value in pairs(server_vehicles) do
        vehicle_count = vehicle_count + 1
    end

    clientDebugPrint("GOT VEHICLE COUNT : ", vehicle_count)

    for k, v in pairs(vehList) do
        local distance = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(v), false)
        local v_plate = GetVehicleNumberPlateText(v)
        -- get the plate of the vehicle and follow rule one
        if distance < 20 and ped ~= v then
            for plate_value, info in pairs(server_vehicles) do
                if tostring(plate_value) == v_plate then
                    local veh_model = GetDisplayNameFromVehicleModel(GetEntityModel(v))
                    clientDebugPrint(GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(v))),
                        GetVehicleModelValue(GetEntityModel(v)))
                    local primary, secondary = GetVehicleColours(v)
                    table.insert(nearby_rentals, {
                        veh = v,
                        plate = v_plate,
                        color = __VEHICLE_COLORS__[primary],
                        model = veh_model,
                        vin = v_plate
                    }) -- get color and model 
                end
            end
        end
    end

    if #nearby_rentals == 0 then
        return 0
    else
        return nearby_rentals
    end
end

function spawnAndCalculateData(data)
    local new_data = data
    -- spawn vehicle
    local model = GetHashKey(data.model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(7)
    end
    currentVeh = CreateVehicle(model, vehicle.x, vehicle.y, vehicle.z, vehicle.w, false, true)
    -- TriggerEvent("nocollision:turnOffCollision", currentVeh)
    ESX.TriggerServerCallback("getRentalCount", function(rental_count)
        SetVehicleNumberPlateText(currentVeh, Config.PlateText .. string.format("%03d", rental_count % 1000))
    end)
    SetVehicleEngineOn(currentVeh, false, true, true)
    Camera()

    -- from vehicle, calculate --> | mph | mpg | seats | storage |
    new_data.mph = math.ceil(GetVehicleEstimatedMaxSpeed(currentVeh) * 2.2369)
    new_data.mpg = exports["legacyfuelredux"]:getFuelRate(currentVeh)
    new_data.seats = GetVehicleMaxNumberOfPassengers(currentVeh) + 1
    new_data.class = GetVehicleClass(currentVeh)
    new_data.storage = exports["mf-inventory"]:getVehicleInventoryTotalSpaceByClass(GetVehicleClass(currentVeh))

    new_data.traction = GetVehicleMaxTraction(currentVeh)
    new_data.acceleration = GetVehicleAcceleration(currentVeh)
    new_data.brand = GetMakeNameFromVehicleModel(model)
    new_data.acceleration = GetVehicleAcceleration(currentVeh)

    return new_data

end

sendRentalUI = function(data)
    SendNUIMessage({
        type = "update",
        data = data
    })
end

getStock = function(model)
    ESX.TriggerServerCallback("getRentalStockByModel", function(stock)
    end, model)
    return stock
end
refreshStock = function()
    ESX.TriggerServerCallback("getVehicleStocks", function(stock)
        veh_stocks = stock
    end)
end

getAvailableSpawn = function(available_spawns)
    if type(available_spawns) ~= "table" then
        return false, false
    end
    local occupied_spots = 0
    for _, location in pairs(available_spawns) do
        -- if vehicle in location try next until index expires
        if ESX.Game.IsSpawnPointClear(vector3(location.x, location.y, location.z), 2) then
            clientDebugPrint("safe space")
            return location, true
        elseif occupied_spots >= #available_spawns then
            clientDebugPrint("getting random location")
            clientDebugPrint(location.x, location.y, location.z)
            break
        end
        clientDebugPrint("OCCUPIED")
        occupied_spots = occupied_spots + 1
    end
    -- if index is past length, retrun first spot with invuln until safe
    local rndIndex = math.random(1, #available_spawns)
    return available_spawns[rndIndex], false

    -- get a random spot, set veh to invuln
end

-- Instead of making safe based on generation, make all veh entities non collidable in a zone 
makeVehicleSafe = function(veh_entity, spawn)
    local not_safe = true
    local vehicle = veh_entity
    Citizen.CreateThread(function()
        local radius = 5
        local spawn_coords = nil
        local veh_coords = GetEntityCoords(vehicle)
        if spawn == nil then
            spawn_coords = GetEntityCoords(vehicle)
        else
            spawn_coords = vector3(spawn.x, spawn.y, spawn.z)
        end

        clientDebugPrint("dont collide")
        while (not_safe) do
            if IsPedInVehicle(GetPlayerPed(), vehicle, false) and
                GetDistanceBetweenCoords(veh_coords.x, veh_coords.y, veh_coords.z, spawn_coords.x, spawn_coords.y,
                    spawn_coords.z, false) < 10 then

                clientDebugPrint("vehicles in area\n")
                not_safe = true
            else
                clientDebugPrint("left area")
                not_safe = false
            end
            veh_coords = GetEntityCoords(vehicle)
            Citizen.Wait(500)
        end
        -- Turn collision on
        toggleNoCollision(vehicle, false)
    end)
end

makeVehicleUnSafe = function(veh_entity)
end

function toggleNoCollision(vehicle, starter)
    Citizen.CreateThread(function()
        clientDebugPrint("collision = ", starter)
        if not starter then
            SetEntityNoCollisionEntity(v, vehicle, false)
        end
        local close_vehicle = false
        local collision_list = {}
        local lock = starter
        while lock do
            local close_veh = 0
            local veh = vehicle
            local vehList = GetGamePool('CVehicle')
            local ped = PlayerPedId()

            for k, v in pairs(vehList) do
                local distance = GetDistanceBetweenCoords(GetEntityCoords(veh), GetEntityCoords(v), false)
                if distance < 10 and veh ~= v then
                    close_vehicle = true
                    close_veh = close_veh + 1
                    collision_list[v] = true
                    SetEntityNoCollisionEntity(v, veh, false)
                    clientDebugPrint("-- DMG OFF --")
                elseif not isEmpty(collision_list) and collision_list[v] then
                    SetEntityNoCollisionEntity(v, veh, true)
                    collision_list[v] = false
                end
            end
            clientDebugPrint("NUMBER OF VEH", close_veh)
            if close_veh == 0 then
                lock = false
                SetEntityNoCollisionEntity(v, veh, true)
                clientDebugPrint("++ DMG ON ++")
            end
            Citizen.Wait(500)
            clientDebugPrint("SEATED", IsPedInVehicle(ped, veh, false))

            if not IsPedInVehicle(ped, veh, false) then
                lock = false
            end
        end
    end)
end

-- HELPER FUNCTIONS
function isEmpty(value)
    if value == nil or value == "" then
        return true
    else
        return false
    end
end

function getSpawnLocations(label)
    return Config.Locations[label].spawns
end

function second(time)
    local minutes = math.floor((time % 3600 / 60))
    local seconds = math.floor((time % 60))
    return string.format("%02dm %02ds", minutes, seconds)
end

function papersFor(rental_plate)
    for item, data in pairs(player_papers) do
        clientDebugPrint("Papers For: ", item, data.plate, data.model, data.color, data.vin)
        if tostring(item) == rental_plate then
            return true
        end
    end
    return false
end

-- function hasPapers(plate_name)
--     return (TriggerServerEvent("rentacar:hasPapers", plate_name))
-- end
RegisterNetEvent("rentacar:setPapers")
AddEventHandler("rentacar:setPapers", function(papers)
    has_papers = papers
end)

RegisterNetEvent("rentacar:rentalReturned")
AddEventHandler("rentacar:rentalReturned", function(args)
    local plate = args.plate
    local model = args.model
    -- local ped = PlayerPedId()
    local veh_list = getNearbyRentals()

    -- Delete vehicle
    for _, v in pairs(veh_list) do
        if DoesEntityExist(v.veh) and NetworkHasControlOfEntity(v.veh) and v.plate == plate then
            local veh_hash = GetEntityModel(v.veh)
            clientDebugPrint("-- RETURNED HASH --")
            clientDebugPrint(veh_hash)
            clientDebugPrint("Hash: ", veh_hash, "Name: ", __VEHICLE_HASH__[veh_hash].name, "Class: ",
                GetVehicleClassFromName(veh_hash))
            local veh_model = string.lower(__VEHICLE_HASH__[veh_hash].name)

            ESX.Game.DeleteVehicle(v.veh)
            -- Delete Inventory
            TriggerServerEvent("rentacar:deleteInventory", v.plate, veh_model)
            -- Update Stock
            TriggerServerEvent("rentacar:returnedStock", veh_model)

            -- Return deposit to player
            local deposit = 0
            for _, vehicle in pairs(Config.Vehicles) do
                if vehicle.model == veh_model then
                    deposit = vehicle.deposit
                    break
                end
            end
            TriggerServerEvent("rentacar:giveDeposit", deposit)
            -- Delete Keys
            TriggerServerEvent('keys:deleteCarKeys', v.plate, "rental")
            break
        end
    end
    refreshStock()

end)

-- MENU GENERATOR
-- Main Menu
callMainMenuUI = function(label)
    clientDebugPrint("CALLED MAIN MENU")
    ESX.TriggerServerCallback("rentacar:getPlayerRentals", function(vehicle_list)
        server_vehicles = vehicle_list
    end)
    ESX.TriggerServerCallback("rentacar:getPlayerPapers", function(papers)
        player_papers = papers
    end)
    local comp_options = {{
        title = "Return Vehicle",
        description = "",
        arrow = true,
        icon = "square-parking",
        iconColor = "#eee813",
        onSelect = function()
            composeNearbySelections()
        end
    }, {
        title = "View Rentals",
        description = "",
        arrow = true,
        icon = "key",
        iconColor = "#1394ee",
        onSelect = function()
            callRentalMenuUI()
        end
    }}

    lib.registerContext({
        id = 'main_menu',
        title = Config.Locations[label].label,
        options = comp_options,
        onExit = function()
            SendNUIMessage({
                type = "ui",
                data = false
            })
            TriggerEvent("rentacar:exit")
        end

    })
    lib.showContext('main_menu')

end

-- RETURN CHOICES
callReturnMenuUI = function()
    -- scan area radius from vendor, return list of supported vehicles*
    -- *supported vehicles must exist in current server list
end
-- RENTAL CHOICES
callRentalMenuUI = function()
    local comp_options = {}
    comp_options = {{
        title = " Go Back",
        description = "",
        icon = "angle-left",
        onSelect = function()
            callMainMenuUI("Touchdown Rentals")
        end
    }}
    for k, v in pairs(Config.Vehicles) do
        local available_text = "  |  Available"
        local icon_color = "#67ee7f"
        if (veh_stocks[v.model] <= 0) then
            available_text = ""
            icon_color = "#8a3737"
        elseif (veh_stocks[v.model] <= 5) then
            available_text = "  |  Low"
            icon_color = "#f9ab53"
        end

        comp_options[k + 1] = {
            title = Config.Vehicles[k].label,
            description = "Due: $" .. (Config.Vehicles[k].price + Config.Vehicles[k].deposit) .. available_text,
            arrow = true,
            icon = Config.Vehicles[k].icon,
            iconColor = icon_color,
            event = "rentacar:previewRentalView",
            args = Config.Vehicles[k], -- Table containing: model | label | price | stock
            onSelect = TriggerEvent("rentacar:cleanupPreviewArea")
        }
    end
    lib.registerContext({
        id = 'rental_menu',
        title = "🏈 Touchdown Rentals",
        options = comp_options,
        onExit = function()
            SendNUIMessage({
                type = "ui",
                data = false
            })
            TriggerEvent("rentacar:exit")
        end

    })
    lib.showContext('rental_menu')

end

-- Rental Preview (Looking at Car Selected)
previewRentalView = function(data)
    local event_function = nil
    local desc = "Out of Stock"
    local icon_color = "#8a3737"

    if (veh_stocks[data.model] > 0) then
        event_function = "rentacar:rentVehicle"
        desc = "$" .. (data.price + data.deposit) .. " | Pay Now"
        icon_color = "#67ee7f"
    end

    local comp_options = {{
        title = " Go Back",
        description = "",
        icon = "angle-left",
        event = "rentacar:exitPreview",
        onSelect = function()
            callRentalMenuUI()
        end

    }, {
        title = "$" .. data.deposit .. " | Deposit",
        description = "(Returned upon dropoff)",
        icon = "money-bill-transfer",
        arrow = false,
        disabled = true
    }, {
        title = "$" .. data.price .. " | Fee",
        description = "(You thought it was free?)",
        icon = "money-bill-wave",
        arrow = false,
        disabled = true
    }, {
        title = data.label,
        description = desc,
        arrow = false,
        event = event_function,
        icon = "cash-register",
        iconColor = icon_color,
        args = {
            data = data,
            spawns = getSpawnLocations("Touchdown Rentals")
        }
    }}

    lib.registerContext({
        id = 'rental_menu2',
        title = "🏈 Touchdown Rentals",
        options = comp_options,
        onExit = function()
            SendNUIMessage({
                type = "ui",
                data = false
            })
            SetNuiFocus(false, false)
            TriggerEvent("rentacar:exit")
        end

    })

    lib.showContext('rental_menu2')
    TriggerEvent("ox_lib:enableKeys", "rentacar")
end

-- MENU HELPERS

function composeNearbySelections()
    local comp = {}
    local rentals = getNearbyRentals() or 0 -- return -1 if no rental for user

    comp = {{
        title = " Go Back",
        description = "",
        icon = "angle-left",
        event = "rentacar:exitPreview",
        onSelect = function()
            callMainMenuUI("Touchdown Rentals")
        end

    }}
    if type(rentals) ~= "table" or rentals == 0 then
        table.insert(comp, {
            title = "No Rental Nearby",
            description = "move vehicle closer",
            arrow = false,
            disabled = true,
            icon = "car",
            iconColor = "#878787"
        })
    else
        for _, v in pairs(rentals) do
            local papers = papersFor(v.plate)
            local icon_col = "#878787"
            local paper_text = "[ MISSING PAPERS ]"
            if papers then
                paper_text = ""
                icon_col = "#67ee7f"
            else
                icon_col = "#8a3737"
            end
            table.insert(comp, {
                title = v.model,
                disabled = not papers,
                description = "PLATE: " .. v.plate,
                arrow = false,
                icon = "car",
                iconColor = icon_col,
                metadata = {v.color, paper_text},
                event = "rentacar:rentalReturned",
                args = {
                    model = v.model,
                    color = v.color,
                    plate = v.plate,
                    vin = v.vin
                }
            })

        end
    end

    lib.registerContext({
        id = 'return_menu',
        title = "🏈 Touchdown Rentals",
        description = "Return Rentals",
        options = comp,
        onExit = function()
            SendNUIMessage({
                type = "ui",
                data = false
            })
            SetNuiFocus(false, false)
            TriggerEvent("rentacar:exit")
        end

    })
    lib.showContext('return_menu')

end

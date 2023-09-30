local player_rentals = {}
local num_of_rentals = 1
local veh_stocks = {}

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
    setVehicleStocksFromConfig()
    player_rentals = {}
end)

RegisterServerEvent("rentacar:setInitialStocks")
AddEventHandler("rentacar:setInitialStocks", function()
    setVehicleStocksFromConfig()
end)

local function isempty(s)
    return s == nil or s == ''
end
RegisterServerEvent("rentacar:giveDeposit")
AddEventHandler("rentacar:giveDeposit", function(money)
    print("[rentacar:giveDeposit] ", source, money)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.addAccountMoney("money", money)

end)

ESX.RegisterServerCallback("isPrice", function(source, cb, money, veh_model)
    local Player = ESX.GetPlayerFromId(source)
    local player_rentals = getPlayerRentalCount(source)
    local model = string.lower(veh_model)
    serverDebugPrint("--------- PLAYER RENTALS ----------- ", player_rentals, " | ", Config.MaxRentals)
    if isempty(model) then
        cb("no_vehicle")
        return
    elseif player_rentals >= Config.MaxRentals then
        serverDebugPrint("                    MAX RENTALS                       ")
        cb("max_rentals")
        return
    elseif not isempty(veh_stocks[model]) and veh_stocks[model] > 0 then
        if Player.getMoney() >= tonumber(money) then
            veh_stocks[model] = veh_stocks[model] - 1
            Player.removeMoney(tonumber(money))
            cb(true)
        else
            cb("broke")
        end
        return
    elseif not isempty(veh_stocks[model]) and veh_stocks[model] <= 0 then
        cb("no_stock")
        return
    end

    if Player.getMoney() >= tonumber(money) then
        Player.removeMoney(tonumber(money))
        cb(true)
    else
        cb("broke")
    end
end)

ESX.RegisterServerCallback("getRentalCount", function(source, cb)
    cb(num_of_rentals)
end)
ESX.RegisterServerCallback("getRentalStockByModel", function(source, cb, veh_model)
    local model = string.lower(veh_model)
    cb(veh_stocks[model])
end)

ESX.RegisterServerCallback("getVehicleStocks", function(source, cb)
    cb(veh_stocks)
end)

ESX.RegisterServerCallback("getCurrentRentalPlate", function(source, cb)
    cb(Config.PlateText .. string.format("%03d", num_of_rentals % 1000))
end)

ESX.RegisterServerCallback("createRenterPlate", function(source, cb)
    cb(Config.PlateText .. string.format("%03d", num_of_rentals % 1000))
    num_of_rentals = num_of_rentals + 1
end)

function setVehicleStocksFromConfig()
    for _, value in pairs(Config.Vehicles) do
        if value["stock"] ~= nil then
            veh_stocks[value["model"]] = value["stock"]
        end
    end
end

RegisterServerEvent("rentacar:returnedStock")
AddEventHandler("rentacar:returnedStock", function(this_model)
    -- add back to stock
    local model = string.lower(this_model)
    veh_stocks[model] = veh_stocks[model] + 1
end)

RegisterServerEvent("rentacar:setClientRentals")
AddEventHandler("rentacar:setClientRentals", function(src, plate_name, model_name, color_number, vin_number)
    -- setClientRentals(source, rental_plate) --> none
    -- put rental plate to playerid (uuid, not server id) on rental

    serverDebugPrint("[setClientRentals] ", src, plate_name, model_name, color_number, vin_number)
    local player_id = src or source
    local plate = plate_name
    local model = model_name or false
    local color = color_number or false
    local vin = vin_number or false
    local uuid = getRockstarID(source)
    if player_rentals[uuid] == nil or player_rentals[uuid] == false then
        player_rentals[uuid] = {}
    end

    player_rentals[uuid][plate] = {
        plate = plate,
        model = model,
        color = color,
        vin = vin
    }

    for plate, vehicle_info in pairs(player_rentals[uuid]) do
        if vehicle_info ~= false then
            serverDebugPrint(uuid, " | has rental plate | ", plate)
        end
    end
    for k, v in pairs(player_rentals[uuid]) do
        serverDebugPrint(k)
        serverDebugPrint(v.plate)
        serverDebugPrint(v.model)
        serverDebugPrint(v.color)
        serverDebugPrint(v.vin)
    end
    getActiveRentalCount()
end)

ESX.RegisterServerCallback("rentacar:getPlayerRentals", function(source, cb)
    local player_id = src or source
    local plate = plate_name or false
    local uuid = getRockstarID(source)
    if player_rentals[uuid] == nil or player_rentals[uuid] == false then
        serverDebugPrint("[rentacar:getPlayerRentals] Player has no rental!")
        cb({})
    else
        local count = 0
        for _, v in pairs(player_rentals[uuid]) do
            serverDebugPrint(_)
            count = count + 1
        end
        serverDebugPrint("[rentacar:getPlayerRentals] Player has {" .. count .. "} rental(s)!")
        cb(player_rentals[uuid])
    end

end)

function getPlayerRentalCount(src)
    local player_id = src or source
    local rentals = player_rentals[getRockstarID(player_id)]
    if type(rentals) == "table" then
        return #rentals
    elseif rentals ~= nil and rentals ~= false then
        return 1
    else
        return 0
    end

end

function getActiveRentalCount()
    local number_of_rentals = 0
    -- count the number of active rentals in table
    for player, vehicle_plate in pairs(player_rentals) do
        if vehicle_plate ~= false then
            serverDebugPrint(player, " | has rental plate | ", vehicle_plate)
            number_of_rentals = number_of_rentals + 1
        end
    end
    if number_of_rentals == 0 then
        serverDebugPrint("No rentals")
    end

    -- return count
    return number_of_rentals
end

ESX.RegisterServerCallback("hasActiveRental", function(source, cb)
    -- (source) --> player_has_rental: bool
    -- add a check to see if player has active rental (this will allow rental limits, and allow client to receive keys on login)
    -- if #player_rentals
    cb(Config.PlateText .. string.format("%03d", num_of_rentals % 1000))
    num_of_rentals = num_of_rentals + 1
end)

function getRockstarID(source)
    local player_id = source
    local identifier
    for k, v in ipairs(GetPlayerIdentifiers(player_id)) do
        if string.match(v, 'license') then
            identifier = v
            break
        end
    end

    return identifier
end

-- See if player has rental papers on them
-- RegisterServerEvent("rentacar:hasPapers")
-- AddEventHandler("rentacar:hasPapers", function(src, plate_name)
ESX.RegisterServerCallback("rentacar:hasPapers", function(source, cb, plate_name, model, color, vin)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rental_item = "document_vehicle_rental"
    local has_papers = false
    serverDebugPrint(#xPlayer.getInventory(true))
    for _, v in pairs(xPlayer.getInventory(true)) do
        if v.count >= 1 and v.name == rental_item then
            serverDebugPrint("FOUND")
            serverDebugPrint(v.name)
            if v.meta.plate == plate_name and v.meta.color == color and v.meta.model == model and v.vin == vin then
                has_papers = true
                serverDebugPrint("MATCHING PAPERS!!")
                break
            else
                serverDebugPrint("PAPERS DONT MATCH: ")
                serverDebugPrint(v.meta.plate, plate_name)
                serverDebugPrint(v.meta.color, color)
                serverDebugPrint(v.meta.model, model)
                serverDebugPrint(v.meta.vin, vin)
            end
        else
            has_papers = false
        end
    end

    serverDebugPrint(has_papers)
    TriggerClientEvent("rentacar:setPapers", source, has_papers)

end)

ESX.RegisterServerCallback("rentacar:getPlayerPapers", function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rental_item = "document_vehicle_rental"
    local paper_list = {}
    local uuid = getRockstarID(source)

    if player_rentals[uuid] == nil or player_rentals[uuid] == false then
        serverDebugPrint("nothing found")
        cb({})
        return
    end
    for _, v in pairs(xPlayer.getInventory(true)) do
        if v.count >= 1 and v.name == rental_item then
            serverDebugPrint("FOUND")
            serverDebugPrint(v.name)

            for plate, plate_info in pairs(player_rentals[uuid]) do
                if v.meta.plate == plate and v.meta.plate == plate_info.plate and v.meta.model == plate_info.model and
                    v.meta.color == plate_info.color and v.meta.vin == plate_info.vin then
                    serverDebugPrint("MATCHING PAPERS!!")
                    paper_list[plate] = plate_info
                    break
                end
            end
        end
    end
    -- if has_papers then
    for _, v in pairs(paper_list) do
        serverDebugPrint("ID: ", _, "INFO: ", v.plate, v.model, v.color, v.vin)
    end
    cb(paper_list)

end)

RegisterServerEvent("rentacar:deleteInventory")
AddEventHandler("rentacar:deleteInventory", function(plate, model)
    local xPlayer = ESX.GetPlayerFromId(source)
    local uuid = getRockstarID(source)
    local this_plate = plate
    local this_model = string.lower(model)

    serverDebugPrint(this_model, this_plate)

    -- remove from all entries
    for _, v in pairs(player_rentals) do
        for key, value in pairs(v) do
            if value == this_plate then
                table.remove(v, key)
            end
        end
    end
    local glovebox = tostring("glovebox_" .. this_plate)

    -- Delete Inventory of Vehicle
    exports["mf-inventory"]:deleteInventory(this_plate)
    exports["mf-inventory"]:deleteInventory(glovebox)
    -- Delete Inventory Item of player
    for _, v in pairs(xPlayer.getInventory(true)) do
        if v.count >= 1 and v.name == "document_vehicle_rental" and v.meta.plate == this_plate then
            xPlayer.removeInventoryItem(v.name, 1, true, v.meta)
        end
    end

end)

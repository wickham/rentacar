local num_of_rentals = 1
local veh_stocks = {}

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource then
        return
    end
    SetVehicleStocksFromConfig()
end)

RegisterServerEvent("es-rentacar:setInitialStocks")
AddEventHandler("es-rentacar:setInitialStocks", function()
    SetVehicleStocksFromConfig()
end)

ESX.RegisterCommand('rrefresh', 'admin', function(xPlayer, args, showError)
    SetVehicleStocksFromConfig()
end, false, {
    help = 'Refresh rental stock!'
})

ESX.RegisterCommand('rstock', 'admin', function(xPlayer, args, showError)
    GetVehicleStocks()
end, false, {
    help = 'Get rental stock!'
})

ESX.RegisterCommand('rmen', 'admin', function(xPlayer, args, showError)
    TriggerClientEvent("rmen", -1)
end, false, {
    help = 'Get rental stock!'
})

local function isempty(s)
    return s == nil or s == ''
end

ESX.RegisterServerCallback("isPrice", function(source, cb, money, veh_model)
    local Player = ESX.GetPlayerFromId(source)
    if isempty(veh_model) then
        cb("no_vehicle")
        return
    elseif not isempty(veh_stocks[veh_model]) and veh_stocks[veh_model] > 0 then
        if Player.getMoney() >= tonumber(money) then
            veh_stocks[veh_model] = veh_stocks[veh_model] - 1
            Player.removeMoney(tonumber(money))
            cb(true)
        else
            cb("broke")
        end
        return
    elseif not isempty(veh_stocks[veh_model]) and veh_stocks[veh_model] <= 0 then
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
    cb(veh_stocks[veh_model])
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

function GetVehicleStocks()
    return veh_stocks
end

function SetVehicleStocksFromConfig()
    for _, value in pairs(Config.Vehicles) do
        if value["stock"] ~= nil then
            veh_stocks[value["model"]] = value["stock"]
        end
    end
end

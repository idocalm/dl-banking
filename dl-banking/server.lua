local QBCore
TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)


RegisterNetEvent("dl-banking:server:requestOpen")
AddEventHandler("dl-banking:server:requestOpen", function() 
    local src = source
    local player = QBCore.Functions.GetPlayer(source)
    local pName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    local pBalance = player.PlayerData.money.bank

    local data =  {
        name = pName, 
        balance = pBalance,
        time = os.date("%H") .. ":".. os.date("%M"),
        payments = {}
    }

    local citizenId = player.PlayerData.citizenid;
    QBCore.Functions.ExecuteSql(false, "SELECT * FROM `banking-payments` WHERE `player` = '"..citizenId.."'", function(result)
        if result[1] then
            data.payments = json.encode(result)
        end
    end)
    Wait(200)
    TriggerClientEvent("dl-banking:client:openUI", src, data)
end)


RegisterServerEvent("dl-banking:server:withdraw", function(withdrawAmount)
    local player = QBCore.Functions.GetPlayer(source)
    local currentBank = player.PlayerData.money.bank
    if (withdrawAmount <= currentBank) then
        TriggerClientEvent("dl-banking:client:updateNUI", source, "balance", player.PlayerData.money.bank - withdrawAmount)

        player.Functions.RemoveMoney("bank", withdrawAmount)
        player.Functions.AddMoney("cash", withdrawAmount)
    else
        TriggerClientEvent("dl-banking:client:notify", source, "you are not that rich mate")
    end

end)

RegisterServerEvent("dl-banking:server:deposit", function(depositAmount)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local currentCash = player.PlayerData.money.cash
    if (depositAmount <= currentCash) then
        TriggerClientEvent("dl-banking:client:updateNUI", src, "balance", player.PlayerData.money.bank + depositAmount)

        player.Functions.RemoveMoney("cash", depositAmount)
        player.Functions.AddMoney("bank", depositAmount)
    else
        TriggerClientEvent("dl-banking:client:notify", source, "you are not that rich mate")

    end

end)

RegisterServerEvent("dl-banking:server:transfer", function(transferAmount, pId)
    local src = source
    local sourcePlayer = QBCore.Functions.GetPlayer(src)
    local transferPlayer = QBCore.Functions.GetPlayer(tonumber(pId))
    if tonumber(src) ~= tonumber(pId) then
        if transferPlayer ~= nil and sourcePlayer ~= nil then
                if tonumber(sourcePlayer.PlayerData.money.bank) >= tonumber(transferAmount) then
                    sourcePlayer.Functions.RemoveMoney("bank", transferAmount)
                    transferPlayer.Functions.AddMoney("bank", transferAmount)
                else
                    TriggerClientEvent("dl-banking:client:notify", source, "you are not that rich mate")

                end
        else
            TriggerClientEvent("dl-banking:client:notify", source, "player is offline")

        end
    else
        TriggerClientEvent("dl-banking:client:notify", source, "yo don't try to break me mf")

    end

end)


RegisterCommand('money', function(source, args, rawCommand)
    local _source = source
	local xPlayer = QBCore.Functions.GetPlayer(_source)
	local cash = xPlayer.PlayerData.money["cash"]
    local bank = xPlayer.PlayerData.money["bank"]

    TriggerClientEvent("QBCore:Notify", _source, "You have " .. cash .. "$ on cash and " ..bank .. "$ in the bank")
end)


RegisterCommand("transfercash", function(source, args, rawCommand)
    -- transfercash [id] [amount]
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local transferPlayer = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if transferPlayer ~= nil then
        if xPlayer.PlayerData.money.cash >= tonumber(args[2]) then
            xPlayer.Functions.RemoveMoney("cash", tonumber(args[2]))
            transferPlayer.Functions.AddMoney("cash", tonumber(args[2]))
            TriggerClientEvent("QBCore:Notify", src, "Money transfered successfully.")
            TriggerClientEvent("QBCore:Notify", tonumber(args[1]), "Your received " .. args[2] .. "$ from " ..  xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)
        else
            TriggerClientEvent("QBCore:Notify", src, "You don't have enough money.")
        end
    else
        TriggerClientEvent("QBCore:Notify", src, "Player is offline.")
    end
end)


RegisterCommand("ticket", function(source, args)
    local player = QBCore.Functions.GetPlayer(source)
    if player.PlayerData.job.name == "police" then
        TriggerClientEvent("dl-banking:client:getClosestPed", source, args[1])
    else
        TriggerClientEvent("QBCore:Notify", source, "You are not a policeman")
    end
end)

RegisterNetEvent("dl-banking:server:getClosestPed", function(closestPed, id, amount)
    print(closestPed, id)
    if closestPed ~= -1 and closestPed ~= false then
        local target = QBCore.Functions.GetPlayer(id)
        local player = QBCore.Functions.GetPlayer(source)
        QBCore.Functions.ExecuteSql(false, "INSERT INTO `phone_invoices` (`sender`, `citizenid`, `amount`, `invoiceid`) VALUES ('" .. player.PlayerData.citizenid .. "', '" .. target.PlayerData.citizenid .. "', '" .. amount .. "', '" .. RandomInvoiceId() .. "')")
    else
        TriggerClientEvent("QBCore:Notify", source, "No one is around you, fucking idiot")
    end

end)

RandomInvoiceId = function()
	local InvoiceId = ""
  
	for Index = 0, 3 do
	  InvoiceId = InvoiceId .. tostring(math.random(1, 10))
	end
  
	return InvoiceId
end

function addPaymentToRecords(source, title, money)
    local time = os.date("%H") .. ":".. os.date("%M")
    local player = QBCore.Functions.GetPlayer(source)
    local citizenId = player.PlayerData.citizenid
    QBCore.Functions.ExecuteSql(true, "INSERT INTO `banking-payments` (player, time, money, title) VALUES ('".. citizenId .."','".. time .. "' , '".. money .. "', '" .. title .. "')", function(result) end)
end

exports("addPaymentToRecords", addPaymentToRecords)
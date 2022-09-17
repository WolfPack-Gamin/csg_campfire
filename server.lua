VORP = exports.vorp_inventory:vorp_inventoryApi()


-- item for campfire
Citizen.CreateThread(function()
	Citizen.Wait(2000)
	VORP.RegisterUsableItem(Config.fireStarterItem, function(data)
		local count = VORP.getItemCount(data.source, Config.firewood)
		
		if count >= 3 then
			VORP.subItem(data.source,Config.firewood, Config.startFireAmount)
			TriggerClientEvent('setcampfire', data.source)
		else
			TriggerClientEvent("vorp:TipBottom", data.source, Config.Language.need ..Config.startFireAmount.. Config.Language.toStart, 4000)
		end
	end)

	VORP.RegisterUsableItem(Config.firewood, function(data)
		TriggerClientEvent('addwood', data.source)
	end)

	VORP.RegisterUsableItem(Config.coalItem, function(data)
		TriggerClientEvent('addcoal', data.source)
	end)
end)

RegisterServerEvent('campfire_failed')
AddEventHandler('campfire_failed', function()
	local _source = source
	VORP.addItem(_source, Config.firewood, Config.startFireAmount)
	TriggerClientEvent("vorp:TipBottom", _source, Config.Language.failed, 4000)		
end)

RegisterServerEvent('addwood_server')
AddEventHandler('addwood_server', function()
	local _source = source
	VORP.subItem(_source,Config.firewood, 1)
	TriggerClientEvent("vorp:TipBottom", _source, Config.Language.woodAdded, 4000)		
end)

RegisterServerEvent('addcoal_server')
AddEventHandler('addcoal_server', function()
	local _source = source
	VORP.subItem(_source,Config.coalitem, 1)
	TriggerClientEvent("vorp:TipBottom", _source, Config.Language.coalAdded, 4000)		
end)



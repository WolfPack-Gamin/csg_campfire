
local campfire = 0
local campfirePositive = false
local campfireTimer = 0
local x,y,z = 0

--setting 
RegisterNetEvent('setcampfire')
AddEventHandler('setcampfire', function()
    if campfire ~= 0 then
        SetEntityAsMissionEntity(campfire)
        DeleteObject(campfire)
        campfire = 0
    end
    local playerPed = PlayerPedId()
    TriggerEvent("vorp_inventory:CloseInv");
    TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 30000, true, false, false, false)
    Citizen.Wait(2000)
    local test = exports["syn_minigame"]:taskBar(Config.miniGameDifficulty,7) -- difficulty,skillGapSent
    if test == 100 then
        exports['progressBars']:startUI(2000, Config.Language.fireProgressBar)
        Citizen.Wait(2000)
        ClearPedTasksImmediately(PlayerPedId())
        x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, -1.55))
        print(x,y,z)
        local prop = CreateObject(GetHashKey(Config.campfireProp), x, y, z, true, false, true)
        SetEntityHeading(prop, GetEntityHeading(PlayerPedId()))
        PlaceObjectOnGroundProperly(prop)
        campfire = prop
        campfireTimer = Config.fireBaseTime
        campfirePositive = true
        Citizen.CreateThread(CampfireThreadTimer)
    else
        TriggerServerEvent('campfire_failed')
        ClearPedTasksImmediately(PlayerPedId())
    end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1)
        -- Citizen.CreateThread(CampfireThreadTimer)
		local pos = GetEntityCoords(PlayerPedId(), true)
        if campfire ~= 0 then
            if GetDistanceBetweenCoords(x,y,z, pos.x, pos.y, pos.z, true) < 5.0 then
                DrawText3D(x,y,z+1.5, Config.Language.fireTimer .. campfireTimer)
            end
        end
	end
end)

RegisterCommand("putout", function(source, args) --command used for testing only
    if campfire == 0 then
        -- print("There is no campfire.")
    else
        SetEntityAsMissionEntity(campfire)
        DeleteObject(campfire)
        campfire = 0
        campfirePositive = false
        campfireTimer = 0
    end
end)

--deleting
RegisterNetEvent('delcampfire')
AddEventHandler('delcampfire', function()
    if campfire == 0 then
        -- print("There is no campfire.")
    else
        SetEntityAsMissionEntity(campfire)
        DeleteObject(campfire)
        campfire = 0
    end
end)

RegisterNetEvent('addwood')
AddEventHandler('addwood', function()
    if campfire ~= 0 then
        local pos = GetEntityCoords(PlayerPedId(), true)
        if GetDistanceBetweenCoords(x,y,z, pos.x, pos.y, pos.z, true) < 2.0 then
            local playerPed = PlayerPedId()
            TriggerEvent("vorp_inventory:CloseInv");
            TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 30000, true, false, false, false)
            exports['progressBars']:startUI(3000, Config.Language.addingWood)
            Citizen.Wait(3000)
            TriggerServerEvent('addwood_server')
            campfireTimer = campfireTimer + Config.woodAddTime
            ClearPedTasksImmediately(PlayerPedId())
        else
            TriggerEvent("vorp:TipBottom", Config.Language.tooFar, 4000)
        end
    else
        -- print("There is no campfire.")
        TriggerEvent("vorp:TipBottom", Config.Language.noFire, 4000)	
    end
end)

RegisterNetEvent('addcoal')
AddEventHandler('addcoal', function()
    if campfire ~= 0 then
        local pos = GetEntityCoords(PlayerPedId(), true)
        if GetDistanceBetweenCoords(x,y,z, pos.x, pos.y, pos.z, true) < 2.0 then
            local playerPed = PlayerPedId()
            TriggerEvent("vorp_inventory:CloseInv");
            TaskStartScenarioInPlace(playerPed, GetHashKey('WORLD_HUMAN_CROUCH_INSPECT'), 30000, true, false, false, false)
            exports['progressBars']:startUI(3000, Config.Language.addingCoal)
            Citizen.Wait(3000)
            TriggerServerEvent('addcoal_server')
            campfireTimer = campfireTimer + Config.coalAddTime
            ClearPedTasksImmediately(PlayerPedId())
        end
    else
        -- print("There is no campfire.")
        TriggerEvent("vorp:TipBottom", Config.Language.noFire, 4000)	
    end
end)

function CampfireThreadTimer()
    while campfirePositive do
        Wait(1000)
        if campfireTimer == 0 then
            campfirePositive = false
            TriggerEvent('delcampfire')
        else
            campfireTimer = campfireTimer - 1
        end
    end
end

function DrawText3D(x, y, z, text)
    local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())  
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 5)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    if onScreen then
      SetTextScale(0.30, 0.30)
      SetTextFontForCurrentCommand(1)
      SetTextColor(255, 255, 255, 215)
      SetTextCentre(1)
      DisplayText(str,_x,_y)
      local factor = (string.len(text)) / 225
      DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
    end
end
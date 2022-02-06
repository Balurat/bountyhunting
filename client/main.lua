--[[
    Commants                        | description
    --------------------------------|------------------------------
    bountyhuntermenu                | toggles the menu on and of
    gatherinformation [bountyID]    | displays to the player when the bounty was last seen in the town
    gahterinformation               | displays to the player when any bounty hunter has last asked for him

    TODO:
    # Get the current bounty status of own character
        - Once while logging in and then in case a bounty is set/removed while online
    # Gather Information
        - if a ID is given, the server responds with the information about the bounty
            - if the ID is invalid, no information is given
        - if no ID is given, the server responds with information about possible hunters
    # Trace Fugitive Movement
        - Only for players that have an active bounty on their head
        - Every 5 min check the location of the character and report to the server if the location changed
    # Trace Hunter Actions
        - The server keeps track of every hunter action

    IDEAS:
    # Make gathering information a progress
        - Bounty hunter need to interact with npc of a given town to get information
          With more npc interactions, the quality of the information gets better
          Maybe the first knows nothing, the second gives the day of the last sighting, etc.
        - With every bit of information, the player could zero in on the correct direction for the next sighting.
          After a while, he can maybe tell, that the direction was anywhere south. Could be south east or south west though.
          If the last town visit has many sightings, maybe the bounty hunter can narrow it down to south east.
]]

local isNuiOpen   = false
local isFugitive  = true
local bountyStore = nil
local character   = nil
local infoBounty  = {}
local infoHunter  = {}



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) -- every 5 min, could be made random e.g. every 1 to 10 min

        if(isFugitive) then
            -- get coords of player character
            -- check against map to get zone (district and town)
            -- if location has changed, signal server

            local playerCoords = GetEntityCoords(PlayerPedId())
            local zoneTown = Citizen.InvokeNative(0x43AD8FC02B429D33,playerCoords,1)

            if(zoneTown) then
                TriggerEvent("vorp:TipRight", "Deine Anwesenheit wurde bemerkt", 4000) -- from client side
                TriggerServerEvent("bountyhunting:sighting", charId, zoneTown)
            end

        end
    end
end)

function ToggleBountyHunterMenu() 
    isNuiOpen = not isNuiOpen;
    if(isNuiOpen) then
        SendNUIMessage({
            action = "open"
        })
        SetNuiFocus(true, true)
    else 
        SendNUIMessage({type = 'close'})
        SetNuiFocus(false, false)
    end

end

RegisterNUICallback('NUIFocusOff', function()
	SetNuiFocus(false, false)
    SendNUIMessage({type = 'close'})
    isNuiOpen = false
end)


RegisterCommand("bountyhuntermenu", function()
    ToggleBountyHunterMenu()
end)

RegisterCommand("loadbountyinfo", function()
    TriggerServerEvent("bountyhunting:Load")
end)

RegisterCommand("gatherinformation", function(source, args, rawCommand)
    print("Command: gatherinformation")
    local bountyId = args[1] or false
    -- gahter info about bounty
    if(bountyId) then
        local bounty = bountyStore[''..bountyId]
        if(bounty) then
            local bountyInfo = infoBounty[bountyId]
            if(bountyInfo and bountyInfo.lastUpdate > (GetSystemTime() - 300000)) then
                gatherInformation(bountyInfo)
                return
            end

            TriggerServerEvent("bountyhunting:GetSightingsForChar", bounty.charidentifier, bounty.id)
            return
        end
        print("[Fehler] BountyHunting: Kein Bounty mit der angegebenen ID bekannt.")
        return
    end
    -- gather info about hunters
    if(infoHunter.lastUpdate and infoHunter.lastUpdate > (GetSystemTime() - 300000)) then
        gatherInformation()
        return
    end
    TriggerServerEvent("bountyhunting:GetSightingsForChar", character.charIdentifier)
end)

RegisterNetEvent("vorp:SelectedCharacter")
AddEventHandler("vorp:SelectedCharacter", function(charid)
    print("~~ CHARACTER SELECTED ~~")
    TriggerServerEvent("bountyhunting:Load")
end)

-- should be called after character spawn and whenever a bounty is created for this character
RegisterNetEvent("bountyhunting:setState", function(bounties, characterState --[[optional]])
    -- TODO: I would prefere a way to get the character data from vorp clientside
    print("loaded")
    print("character: " .. dump(characterState))
    if(characterState) then character = characterState end
    buildBountyStore(bounties)
end)

RegisterNetEvent("bountyhunting:GetSightingsForChar", function(sightings, charIdentifier, bountyId)
    print("Event: GetSightingsForChar")
    print("sightings: " .. dump(sightings))
    print("bountyId: ".. dump(bountyId))
    if(bountyId) then
        local bountyInfo = {lastUpdate = GetSystemTime(), sightings = sortSightingsByTown(sightings), bountyId = bountyId}
        infoBounty[bountyId] = bountyInfo
        print("infoBounty: " .. dump(infoBounty))
        gatherInformation(bountyInfo)
        return
    end

    infoHunter = {lastUpdate = GetSystemTime(), investigations = sortSightingsByTown(sightings)}
    print("infoHunter: " .. dump(infoHunter))
    gatherInformation()
end)

function gatherInformation(bountyInfo)
    print("Function: gatherInformation")
    local playerCoords = GetEntityCoords(PlayerPedId())
    local zoneTown = Citizen.InvokeNative(0x43AD8FC02B429D33, playerCoords, 1)

    if(not zoneTown) then 
        TriggerEvent("vorp:TipBottom", "Du musst Dich in einer Stadt befinden, um Nachforschungen anstellen zu können", 4000)
        return 
    end

    -- gather information about bounty
    if(bountyInfo) then
        TriggerServerEvent("bountyhunting:sighting", bountyStore[""..bountyInfo.bountyId].charidentifier, zoneTown, true)
        local sightings = bountyInfo.sightings[""..zoneTown]
        if(sightings) then
            TriggerEvent("vorp:NotifyLeft", "Die gesuchte Person wurde gesehen", "In der letzten Woche " .. #sightings .. "x", "generic_textures", "tick", 10000)
            return
        end
        TriggerEvent("vorp:NotifyLeft", "Die gesuchte Person wurde hier nicht gesehen", "Leider wurde hier keine Person gesehen, auf die die Beschreibung zutreffen könnte. Aber das ist auch eine Information.", "generic_textures", "circle", 5000)
        return
    end
    
    -- gather information about hunters
    local investigations = infoHunter.investigations[""..zoneTown]
    if(not investigations) then
        TriggerEvent("vorp:NotifyLeft", "Niemand hat sich erkundigt", "In der letzten Woche hat sich hier niemand nach Dir erkundigt", "generic_textures", "circle", 5000)
        return
    end

    TriggerEvent("vorp:NotifyLeft", "Jemand hat nach Dir gefragt", "Innerhalb der letzten Woche wurde " .. #investigations .. "x nach Dir gefragt.", "generic_textures", "tick", 10000)

end

function buildBountyStore(bounties)
    if type(bounties) == 'table' then
        bountyStore = {}
        local hasBounty = false
        for k,bounty in pairs(bounties) do
            bountyStore['' .. bounty.id] = bounty
            
            if(not hasBounty and bounty.charidentifier == character.charIdentifier) then
                hasBounty = true
            end
        end

        isFugitive = hasBounty
    end
end

function sortSightingsByTown(sightings)
    local result = {}
    if type(sightings) == 'table' then
        for k,sighting in pairs(sightings) do
            local key = '' .. sighting.town
            if(result[key] == nil) then result[key] = {} end
            table.insert(result[key], sighting)
        end
    end
    return result
end


-- Helper function for debug
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
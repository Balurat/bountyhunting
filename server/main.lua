VORP = exports.vorp_core:vorpAPI()

-- after every loading of this resource, delete all sightings older than 7 days
exports.ghmattimysql:execute("DELETE FROM `bounty_sightings` WHERE DATE(tstamp) < DATE_SUB(CURDATE(), INTERVAL 7 DAY)")

RegisterNetEvent('bountyhunting:Load')
AddEventHandler('bountyhunting:Load', function()
    local _source = source
    -- I would prefere a way to get the character data on the client side, but for now this is a acceptable workaround
    local character = VORP.getCharacter(_source)
    exports.ghmattimysql:execute("SELECT * FROM `bounty`", {}, function(bounties) 
        TriggerClientEvent('bountyhunting:setState', _source, bounties, character)
    end)
end)

RegisterServerEvent('bountyhunting:GetSightingsForChar')
AddEventHandler('bountyhunting:GetSightingsForChar', function(charIdentifier, bountyId --[[optional]])
    print("ServerEvent: GetSightingsForChar")
    local _source = source
    exports.ghmattimysql:execute("SELECT id, tstamp, town FROM `bounty_sightings` WHERE `charidentifier` = ? AND `sighting` = " .. (bountyId and "TRUE" or "FALSE"), {charIdentifier}, function(sightings) 
        TriggerClientEvent('bountyhunting:GetSightingsForChar', _source, sightings, charIdentifier, bountyId)
    end)
end)

RegisterServerEvent("bountyhunting:sighting")
AddEventHandler("bountyhunting:sighting", function(charId, town, investigation --[[optional]])
    local _source = source
    local character = VORP.getCharacter(_source)
    exports.ghmattimysql:execute(
        "INSERT INTO `bounty_sightings`(`sighting`, `charidentifier`, `town`) VALUES (?,?,?)", 
        { (investigation and 0 or 1), character.charIdentifier, town }
    )
    
    if(not investigation) then
        print("The fugitive " .. character.firstname .. " " .. character.lastname .. " (" .. character.charIdentifier .. ") was sighted")
    else
        print("The bounty hunter " .. character.firstname .. " " .. character.lastname .. " (" .. character.charIdentifier .. ") made an investigation")
    end
end)

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
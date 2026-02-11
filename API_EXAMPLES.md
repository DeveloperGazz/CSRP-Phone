# CSRP-Phone API Examples

This document shows examples of how to integrate CSRP-Phone with other resources.

## Getting a Player's Phone Number

### Server-Side
```lua
-- Get phone number from server-side
-- Note: Phone numbers are stored in the server/server.lua phoneNumbers table

-- Example: Get phone number by player identifier
RegisterCommand('getmynumber', function(source, args, rawCommand)
    local identifier = GetPlayerIdentifier(source, 0)
    
    MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(number)
        if number then
            TriggerClientEvent('chat:addMessage', source, {
                args = {'System', 'Your phone number is: ' .. number}
            })
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = {'System', 'You do not have a phone number yet'}
            })
        end
    end)
end)

-- Get another player's phone number by their server ID
function GetPlayerPhoneNumber(playerId)
    local identifier = GetPlayerIdentifier(playerId, 0)
    
    MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(number)
        return number
    end)
end
```

### Client-Side
```lua
-- Request your phone number from client
RegisterCommand('requestnumber', function()
    TriggerServerEvent('phone:getPhoneNumber')
end)

-- Receive the phone number
RegisterNetEvent('phone:receivePhoneNumber')
AddEventHandler('phone:receivePhoneNumber', function(phoneNumber)
    print('My phone number is: ' .. phoneNumber)
    -- Store it locally or use it
end)
```

## Sending Automated Messages

### Server-Side
```lua
-- Send a system message to a player
function SendSystemMessage(targetPhoneNumber, message)
    local systemNumber = "911" -- System phone number
    
    MySQL.Async.execute('INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)', {
        ['@sender'] = systemNumber,
        ['@receiver'] = targetPhoneNumber,
        ['@message'] = message
    }, function(rowsChanged)
        if rowsChanged > 0 then
            -- Notify player if online
            local players = GetPlayers()
            for _, playerId in ipairs(players) do
                local identifier = GetPlayerIdentifier(playerId, 0)
                MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
                    ['@identifier'] = identifier
                }, function(number)
                    if number == targetPhoneNumber then
                        TriggerClientEvent('phone:receiveMessage', playerId, systemNumber, message)
                    end
                end)
            end
        end
    end)
end

-- Example: Send welcome message when player joins
AddEventHandler('playerJoining', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    Wait(5000) -- Wait 5 seconds for player to load
    
    MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(number)
        if number then
            SendSystemMessage(number, 'Welcome to the server! Your phone number is ' .. number)
        end
    end)
end)
```

## Creating Custom Phone Apps

You can extend the phone UI by modifying the HTML/CSS/JS files:

### Adding a New App Icon (html/index.html)
```html
<!-- Add to the app-grid div in home-screen -->
<div class="app-icon" onclick="openApp('custom')">
    <span>⚙️</span>
    <p>Settings</p>
</div>
```

### Creating the App Screen (html/index.html)
```html
<!-- Add new screen after other screens -->
<div id="custom-screen" class="screen">
    <div class="screen-header">
        <button class="back-btn" onclick="openApp('home')">← Back</button>
        <h3>Settings</h3>
    </div>
    <div class="screen-body">
        <h4>Phone Settings</h4>
        <p>Your custom content here</p>
    </div>
</div>
```

## Integration with ESX

```lua
-- Server-side example
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Get phone number with ESX
RegisterCommand('esxphone', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier
    
    MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(number)
        TriggerClientEvent('esx:showNotification', source, 'Your number: ' .. number)
    end)
end)

-- Charge for phone calls/messages
RegisterNetEvent('phone:chargeForMessage')
AddEventHandler('phone:chargeForMessage', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if Config.MessageCost > 0 then
        xPlayer.removeMoney(Config.MessageCost)
        TriggerClientEvent('esx:showNotification', src, 'Message sent. Cost: $' .. Config.MessageCost)
    end
end)
```

## Integration with QBCore

```lua
-- Server-side example
QBCore = nil
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

-- Get phone number with QBCore
RegisterCommand('qbphone', function(source, args, rawCommand)
    local Player = QBCore.Functions.GetPlayer(source)
    local identifier = Player.PlayerData.license
    
    MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(number)
        TriggerClientEvent('QBCore:Notify', source, 'Your number: ' .. number, 'success')
    end)
end)
```

## Detecting Active Calls

```lua
-- Client-side: Check if player is in a call
local inCall = false

RegisterNetEvent('phone:callAccepted')
AddEventHandler('phone:callAccepted', function(otherNumber, channel)
    inCall = true
end)

RegisterNetEvent('phone:callEnded')
AddEventHandler('phone:callEnded', function()
    inCall = false
end)

-- Example use: Prevent actions during calls
RegisterCommand('robbank', function()
    if inCall then
        Notify('You cannot rob a bank while on a phone call!')
        return
    end
    -- Continue with bank robbery
end)
```

## Call/Message Logs for Admin

```lua
-- Server-side: Admin command to view recent calls
RegisterCommand('viewcalls', function(source, args, rawCommand)
    -- Check if admin
    if not IsPlayerAceAllowed(source, 'admin') then
        return
    end
    
    if args[1] then
        local phoneNumber = args[1]
        
        MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE caller = @number OR receiver = @number ORDER BY call_time DESC LIMIT 20', {
            ['@number'] = phoneNumber
        }, function(calls)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Admin', 'Recent calls for ' .. phoneNumber .. ':'}
            })
            
            for _, call in ipairs(calls) do
                TriggerClientEvent('chat:addMessage', source, {
                    args = {'', call.caller .. ' -> ' .. call.receiver .. ' (' .. call.call_type .. ')'}
                })
            end
        end)
    end
end)

-- Server-side: Admin command to view messages
RegisterCommand('viewmessages', function(source, args, rawCommand)
    if not IsPlayerAceAllowed(source, 'admin') then
        return
    end
    
    if args[1] then
        local phoneNumber = args[1]
        
        MySQL.Async.fetchAll('SELECT * FROM phone_messages WHERE sender = @number OR receiver = @number ORDER BY sent_at DESC LIMIT 20', {
            ['@number'] = phoneNumber
        }, function(messages)
            TriggerClientEvent('chat:addMessage', source, {
                args = {'Admin', 'Recent messages for ' .. phoneNumber .. ':'}
            })
            
            for _, msg in ipairs(messages) do
                TriggerClientEvent('chat:addMessage', source, {
                    args = {'', msg.sender .. ' -> ' .. msg.receiver .. ': ' .. msg.message}
                })
            end
        end)
    end
end)
```

## Tips

1. **Always check if player has phone number** before sending messages/calls
2. **Use MySQL.Async** for all database operations to avoid blocking
3. **Test thoroughly** after integrating with other resources
4. **Back up database** before making changes to phone tables
5. **Use events** instead of direct function calls for better compatibility

## Need Help?

Refer to the main README.md for more information about the phone system's architecture and available events.

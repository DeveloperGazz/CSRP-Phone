-- Client-side phone script with PMA Voice integration
local phoneOpen = false
local myPhoneNumber = nil
local inCall = false
local currentCallChannel = nil
local incomingCallFrom = nil
local callStartTime = nil

-- Request phone number on spawn
AddEventHandler('playerSpawned', function()
    TriggerServerEvent('phone:getPhoneNumber')
end)

-- Receive phone number from server
RegisterNetEvent('phone:receivePhoneNumber')
AddEventHandler('phone:receivePhoneNumber', function(phoneNumber)
    myPhoneNumber = phoneNumber
    SendNUIMessage({
        type = 'setPhoneNumber',
        phoneNumber = phoneNumber
    })
    -- If phone is open and we just got our number, fetch history/conversations
    if phoneOpen then
        TriggerServerEvent('phone:getCallHistory')
        TriggerServerEvent('phone:getConversations')
    end
end)

-- Open/Close phone
RegisterCommand(Config.OpenPhoneCommand, function()
    TogglePhone()
end)

-- Key mapping for opening phone
RegisterKeyMapping(Config.OpenPhoneCommand, 'Open Phone', 'keyboard', 'F1')

function TogglePhone()
    phoneOpen = not phoneOpen
    SetNuiFocus(phoneOpen, phoneOpen)
    SendNUIMessage({
        type = 'togglePhone',
        show = phoneOpen
    })
    
    if phoneOpen then
        -- Request phone number if we don't have one yet
        if not myPhoneNumber then
            TriggerServerEvent('phone:getPhoneNumber')
        end
        -- Request call history and conversations when opening phone
        if myPhoneNumber then
            TriggerServerEvent('phone:getCallHistory')
            TriggerServerEvent('phone:getConversations')
        end
    end
end

-- Close phone from NUI
RegisterNUICallback('closePhone', function(data, cb)
    ClosePhone()
    cb('ok')
end)

-- Force close phone (always closes, never toggles open)
function ClosePhone()
    if phoneOpen then
        phoneOpen = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            type = 'togglePhone',
            show = false
        })
    else
        -- Ensure NUI focus is released even if state was out of sync
        SetNuiFocus(false, false)
    end
end

-- Start a call
RegisterNUICallback('startCall', function(data, cb)
    if data.phoneNumber then
        TriggerServerEvent('phone:startCall', data.phoneNumber)
    end
    cb('ok')
end)

-- Accept incoming call
RegisterNUICallback('acceptCall', function(data, cb)
    if incomingCallFrom then
        TriggerServerEvent('phone:acceptCall', incomingCallFrom)
    end
    cb('ok')
end)

-- Decline incoming call
RegisterNUICallback('declineCall', function(data, cb)
    if incomingCallFrom then
        TriggerServerEvent('phone:declineCall', incomingCallFrom)
        incomingCallFrom = nil
    end
    cb('ok')
end)

-- End current call
RegisterNUICallback('endCall', function(data, cb)
    if inCall then
        TriggerServerEvent('phone:endCall')
    end
    cb('ok')
end)

-- Send text message
RegisterNUICallback('sendMessage', function(data, cb)
    if data.phoneNumber and data.message then
        TriggerServerEvent('phone:sendMessage', data.phoneNumber, data.message)
    end
    cb('ok')
end)

-- Request messages
RegisterNUICallback('getMessages', function(data, cb)
    TriggerServerEvent('phone:getMessages', data.contactNumber)
    cb('ok')
end)

-- Mark message as read
RegisterNUICallback('markMessageRead', function(data, cb)
    if data.messageId then
        TriggerServerEvent('phone:markMessageRead', data.messageId)
    end
    cb('ok')
end)

-- Incoming call
RegisterNetEvent('phone:incomingCall')
AddEventHandler('phone:incomingCall', function(callerNumber)
    incomingCallFrom = callerNumber
    SendNUIMessage({
        type = 'incomingCall',
        phoneNumber = callerNumber
    })
    
    -- Play ringtone or notification
    PlaySound(-1, "PHONE_RING", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    
    -- Auto-decline after timeout
    SetTimeout(Config.CallRingTime, function()
        if incomingCallFrom == callerNumber then
            TriggerServerEvent('phone:declineCall', callerNumber)
            incomingCallFrom = nil
            SendNUIMessage({
                type = 'callMissed'
            })
        end
    end)
end)

-- Outgoing call
RegisterNetEvent('phone:outgoingCall')
AddEventHandler('phone:outgoingCall', function(receiverNumber)
    SendNUIMessage({
        type = 'outgoingCall',
        phoneNumber = receiverNumber
    })
end)

-- Call accepted
RegisterNetEvent('phone:callAccepted')
AddEventHandler('phone:callAccepted', function(otherNumber, channel)
    inCall = true
    currentCallChannel = channel
    callStartTime = GetGameTimer()
    incomingCallFrom = nil
    
    SendNUIMessage({
        type = 'callAccepted',
        phoneNumber = otherNumber
    })
    
    -- Set PMA Voice call channel
    exports['pma-voice']:setCallChannel(channel)
    
    -- Start call timer
    CreateThread(function()
        while inCall do
            local duration = math.floor((GetGameTimer() - callStartTime) / 1000)
            SendNUIMessage({
                type = 'updateCallDuration',
                duration = duration
            })
            Wait(1000)
        end
    end)
end)

-- Call declined
RegisterNetEvent('phone:callDeclined')
AddEventHandler('phone:callDeclined', function()
    SendNUIMessage({
        type = 'callDeclined'
    })
    Notify('Call declined')
end)

-- Call ended
RegisterNetEvent('phone:callEnded')
AddEventHandler('phone:callEnded', function()
    if inCall then
        -- Leave PMA Voice call channel
        exports['pma-voice']:setCallChannel(0)
        
        inCall = false
        currentCallChannel = nil
        callStartTime = nil
        
        SendNUIMessage({
            type = 'callEnded'
        })
        
        Notify('Call ended')
    end
end)

-- Receive message
RegisterNetEvent('phone:receiveMessage')
AddEventHandler('phone:receiveMessage', function(senderNumber, message)
    SendNUIMessage({
        type = 'receiveMessage',
        phoneNumber = senderNumber,
        message = message
    })
    
    Notify('New message from ' .. senderNumber)
    PlaySound(-1, "PHONE_VIBRATE", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
end)

-- Message sent confirmation
RegisterNetEvent('phone:messageSent')
AddEventHandler('phone:messageSent', function(receiverNumber, message)
    SendNUIMessage({
        type = 'messageSent',
        phoneNumber = receiverNumber,
        message = message
    })
end)

-- Receive call history
RegisterNetEvent('phone:receiveCallHistory')
AddEventHandler('phone:receiveCallHistory', function(calls, myNumber)
    SendNUIMessage({
        type = 'receiveCallHistory',
        calls = calls,
        myNumber = myNumber
    })
end)

-- Receive messages
RegisterNetEvent('phone:receiveMessages')
AddEventHandler('phone:receiveMessages', function(messages, myNumber)
    SendNUIMessage({
        type = 'receiveMessages',
        messages = messages,
        myNumber = myNumber
    })
end)

-- Receive conversations
RegisterNetEvent('phone:receiveConversations')
AddEventHandler('phone:receiveConversations', function(conversations)
    SendNUIMessage({
        type = 'receiveConversations',
        conversations = conversations
    })
end)

-- Notification event
RegisterNetEvent('phone:notify')
AddEventHandler('phone:notify', function(message)
    Notify(message)
end)

-- Notification function
function Notify(message)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(0, 1)
end

-- Clean up on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if inCall then
            exports['pma-voice']:setCallChannel(0)
        end
        SetNuiFocus(false, false)
    end
end)

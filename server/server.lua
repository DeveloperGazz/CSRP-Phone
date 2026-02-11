-- Server-side phone script
local activeCalls = {}
local phoneNumbers = {}

-- Generate a unique phone number (format: 0xxxxxxxxxx)
function GeneratePhoneNumber()
    local number
    local exists = true
    
    while exists do
        number = Config.PhoneNumberPrefix
        for i = 1, Config.PhoneNumberLength do
            number = number .. math.random(0, 9)
        end
        
        -- Check if number already exists
        exists = false
        for _, num in pairs(phoneNumbers) do
            if num == number then
                exists = true
                break
            end
        end
    end
    
    return number
end

-- Get phone number for player (from cache only)
function GetPlayerPhoneNumber(identifier)
    return phoneNumbers[identifier]
end

-- Create phone number for new player
function CreatePhoneNumber(identifier)
    local phoneNumber = GeneratePhoneNumber()
    
    MySQL.Async.execute('INSERT INTO phone_numbers (identifier, phone_number) VALUES (@identifier, @phone_number)', {
        ['@identifier'] = identifier,
        ['@phone_number'] = phoneNumber
    }, function(rowsChanged)
        if rowsChanged > 0 then
            phoneNumbers[identifier] = phoneNumber
            print("Created phone number " .. phoneNumber .. " for " .. identifier)
        end
    end)
    
    return phoneNumber
end

-- Load all phone numbers on startup
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.Async.fetchAll('SELECT identifier, phone_number FROM phone_numbers', {}, function(results)
            for _, row in ipairs(results) do
                phoneNumbers[row.identifier] = row.phone_number
            end
            print("Loaded " .. #results .. " phone numbers")
        end)
    end
end)

-- Assign phone number when player joins
AddEventHandler('playerConnecting', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    if identifier then
        MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(number)
            if not number then
                CreatePhoneNumber(identifier)
            else
                phoneNumbers[identifier] = number
            end
        end)
    end
end)

-- Get player phone number
RegisterNetEvent('phone:getPhoneNumber')
AddEventHandler('phone:getPhoneNumber', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    
    if identifier then
        MySQL.Async.fetchScalar('SELECT phone_number FROM phone_numbers WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(number)
            if not number then
                number = CreatePhoneNumber(identifier)
                Wait(100) -- Wait for database insert
            end
            phoneNumbers[identifier] = number
            TriggerClientEvent('phone:receivePhoneNumber', src, number)
        end)
    end
end)

-- Get player source by phone number
function GetPlayerByPhoneNumber(phoneNumber)
    for identifier, number in pairs(phoneNumbers) do
        if number == phoneNumber then
            for _, playerId in ipairs(GetPlayers()) do
                if GetPlayerIdentifier(playerId, 0) == identifier then
                    return playerId
                end
            end
        end
    end
    return nil
end

-- Start a phone call
RegisterNetEvent('phone:startCall')
AddEventHandler('phone:startCall', function(targetNumber)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local callerNumber = phoneNumbers[identifier]
    
    if not callerNumber then
        TriggerClientEvent('phone:notify', src, 'Error: You do not have a phone number')
        return
    end
    
    local targetPlayer = GetPlayerByPhoneNumber(targetNumber)
    
    if not targetPlayer then
        TriggerClientEvent('phone:notify', src, 'Number not available')
        
        -- Log missed call for caller (outgoing)
        MySQL.Async.execute('INSERT INTO phone_calls (caller, receiver, call_type) VALUES (@caller, @receiver, @call_type)', {
            ['@caller'] = callerNumber,
            ['@receiver'] = targetNumber,
            ['@call_type'] = 'outgoing'
        })
        
        -- Send system text to offline player's phone
        MySQL.Async.execute('INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)', {
            ['@sender'] = 'SYSTEM',
            ['@receiver'] = targetNumber,
            ['@message'] = 'Missed call from ' .. callerNumber
        })
        return
    end
    
    if targetPlayer == src then
        TriggerClientEvent('phone:notify', src, 'You cannot call yourself')
        return
    end
    
    -- Check if target is already in a call
    if activeCalls[targetPlayer] then
        TriggerClientEvent('phone:notify', src, 'Line is busy')
        
        -- Notify caller UI that line is busy
        TriggerClientEvent('phone:lineBusy', src, targetNumber)
        
        -- Send system text to busy player about missed call
        local targetIdentifier = GetPlayerIdentifier(targetPlayer, 0)
        local targetActualNumber = phoneNumbers[targetIdentifier]
        if targetActualNumber then
            MySQL.Async.execute('INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)', {
                ['@sender'] = 'SYSTEM',
                ['@receiver'] = targetActualNumber,
                ['@message'] = 'Missed call from ' .. callerNumber .. ' (you were on another call)'
            })
        end
        
        -- Log missed call
        MySQL.Async.execute('INSERT INTO phone_calls (caller, receiver, call_type) VALUES (@caller, @receiver, @call_type)', {
            ['@caller'] = callerNumber,
            ['@receiver'] = targetNumber,
            ['@call_type'] = 'missed'
        })
        return
    end
    
    -- Send incoming call to target
    TriggerClientEvent('phone:incomingCall', targetPlayer, callerNumber)
    TriggerClientEvent('phone:outgoingCall', src, targetNumber)
end)

-- Accept a phone call
RegisterNetEvent('phone:acceptCall')
AddEventHandler('phone:acceptCall', function(callerNumber)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local receiverNumber = phoneNumbers[identifier]
    
    local callerPlayer = GetPlayerByPhoneNumber(callerNumber)
    
    if not callerPlayer then
        TriggerClientEvent('phone:notify', src, 'Caller is no longer available')
        return
    end
    
    -- Find available call channel
    local callChannel = Config.CallChannel
    for channel, _ in pairs(activeCalls) do
        if type(channel) == "number" and channel >= callChannel then
            callChannel = channel + 1
        end
    end
    
    -- Set up call
    activeCalls[src] = {player = callerPlayer, channel = callChannel, startTime = os.time()}
    activeCalls[callerPlayer] = {player = src, channel = callChannel, startTime = os.time()}
    
    -- Notify both players
    TriggerClientEvent('phone:callAccepted', src, callerNumber, callChannel)
    TriggerClientEvent('phone:callAccepted', callerPlayer, receiverNumber, callChannel)
    
    -- Log call as incoming for receiver
    MySQL.Async.execute('INSERT INTO phone_calls (caller, receiver, call_type) VALUES (@caller, @receiver, @call_type)', {
        ['@caller'] = callerNumber,
        ['@receiver'] = receiverNumber,
        ['@call_type'] = 'incoming'
    })
    
    -- Log call as outgoing for caller
    MySQL.Async.execute('INSERT INTO phone_calls (caller, receiver, call_type) VALUES (@caller, @receiver, @call_type)', {
        ['@caller'] = callerNumber,
        ['@receiver'] = receiverNumber,
        ['@call_type'] = 'outgoing'
    })
end)

-- Decline a phone call
RegisterNetEvent('phone:declineCall')
AddEventHandler('phone:declineCall', function(callerNumber)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local receiverNumber = phoneNumbers[identifier]
    
    local callerPlayer = GetPlayerByPhoneNumber(callerNumber)
    
    if callerPlayer then
        TriggerClientEvent('phone:callDeclined', callerPlayer)
    end
    
    -- Log missed call
    MySQL.Async.execute('INSERT INTO phone_calls (caller, receiver, call_type) VALUES (@caller, @receiver, @call_type)', {
        ['@caller'] = callerNumber,
        ['@receiver'] = receiverNumber,
        ['@call_type'] = 'missed'
    })
end)

-- End a phone call
RegisterNetEvent('phone:endCall')
AddEventHandler('phone:endCall', function()
    local src = source
    
    if activeCalls[src] then
        local otherPlayer = activeCalls[src].player
        local duration = os.time() - activeCalls[src].startTime
        
        -- Update call duration in database
        local identifier = GetPlayerIdentifier(src, 0)
        local myNumber = phoneNumbers[identifier]
        
        if otherPlayer and activeCalls[otherPlayer] then
            local otherIdentifier = GetPlayerIdentifier(otherPlayer, 0)
            local otherNumber = phoneNumbers[otherIdentifier]
            
            -- Update both call records with duration
            MySQL.Async.execute('UPDATE phone_calls SET duration = @duration WHERE caller = @caller AND receiver = @receiver AND duration = 0 ORDER BY call_time DESC LIMIT 1', {
                ['@duration'] = duration,
                ['@caller'] = myNumber,
                ['@receiver'] = otherNumber
            })
            
            MySQL.Async.execute('UPDATE phone_calls SET duration = @duration WHERE caller = @caller AND receiver = @receiver AND duration = 0 ORDER BY call_time DESC LIMIT 1', {
                ['@duration'] = duration,
                ['@caller'] = otherNumber,
                ['@receiver'] = myNumber
            })
            
            TriggerClientEvent('phone:callEnded', otherPlayer)
            activeCalls[otherPlayer] = nil
        end
        
        activeCalls[src] = nil
        TriggerClientEvent('phone:callEnded', src)
    end
end)

-- Handle player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    
    if activeCalls[src] then
        local otherPlayer = activeCalls[src].player
        if otherPlayer and activeCalls[otherPlayer] then
            TriggerClientEvent('phone:callEnded', otherPlayer)
            activeCalls[otherPlayer] = nil
        end
        activeCalls[src] = nil
    end
end)

-- Send text message
RegisterNetEvent('phone:sendMessage')
AddEventHandler('phone:sendMessage', function(targetNumber, message)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local senderNumber = phoneNumbers[identifier]
    
    if not senderNumber then
        TriggerClientEvent('phone:notify', src, 'Error: You do not have a phone number')
        return
    end
    
    if #message > Config.MaxMessageLength then
        TriggerClientEvent('phone:notify', src, 'Message too long')
        return
    end
    
    -- Save message to database
    MySQL.Async.execute('INSERT INTO phone_messages (sender, receiver, message) VALUES (@sender, @receiver, @message)', {
        ['@sender'] = senderNumber,
        ['@receiver'] = targetNumber,
        ['@message'] = message
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('phone:messageSent', src, targetNumber, message)
            
            -- Notify receiver if online
            local targetPlayer = GetPlayerByPhoneNumber(targetNumber)
            if targetPlayer then
                TriggerClientEvent('phone:receiveMessage', targetPlayer, senderNumber, message)
            end
        end
    end)
end)

-- Mark message as read
RegisterNetEvent('phone:markMessageRead')
AddEventHandler('phone:markMessageRead', function(messageId)
    MySQL.Async.execute('UPDATE phone_messages SET is_read = 1 WHERE id = @id', {
        ['@id'] = messageId
    })
end)

-- Get call history
RegisterNetEvent('phone:getCallHistory')
AddEventHandler('phone:getCallHistory', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if phoneNumber then
        MySQL.Async.fetchAll('SELECT * FROM phone_calls WHERE caller = @number OR receiver = @number ORDER BY call_time DESC LIMIT @limit', {
            ['@number'] = phoneNumber,
            ['@limit'] = Config.MaxCallHistory
        }, function(calls)
            TriggerClientEvent('phone:receiveCallHistory', src, calls, phoneNumber)
        end)
    end
end)

-- Get messages
RegisterNetEvent('phone:getMessages')
AddEventHandler('phone:getMessages', function(contactNumber)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if phoneNumber then
        if contactNumber then
            -- Get messages with specific contact
            MySQL.Async.fetchAll('SELECT * FROM phone_messages WHERE (sender = @myNumber AND receiver = @contact) OR (sender = @contact AND receiver = @myNumber) ORDER BY sent_at DESC LIMIT @limit', {
                ['@myNumber'] = phoneNumber,
                ['@contact'] = contactNumber,
                ['@limit'] = Config.MaxMessageHistory
            }, function(messages)
                TriggerClientEvent('phone:receiveMessages', src, messages, phoneNumber)
            end)
        else
            -- Get all messages
            MySQL.Async.fetchAll('SELECT * FROM phone_messages WHERE sender = @number OR receiver = @number ORDER BY sent_at DESC LIMIT @limit', {
                ['@number'] = phoneNumber,
                ['@limit'] = Config.MaxMessageHistory
            }, function(messages)
                TriggerClientEvent('phone:receiveMessages', src, messages, phoneNumber)
            end)
        end
    end
end)

-- Get list of conversations
RegisterNetEvent('phone:getConversations')
AddEventHandler('phone:getConversations', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if phoneNumber then
        MySQL.Async.fetchAll([[
            SELECT 
                CASE 
                    WHEN pm.sender = @number THEN pm.receiver 
                    ELSE pm.sender 
                END AS contact,
                pm.message,
                pm.sent_at,
                pm.is_read,
                pm.id
            FROM phone_messages pm
            INNER JOIN (
                SELECT 
                    CASE 
                        WHEN sender = @number THEN receiver 
                        ELSE sender 
                    END AS contact_number,
                    MAX(sent_at) AS max_sent_at
                FROM phone_messages
                WHERE sender = @number OR receiver = @number
                GROUP BY contact_number
            ) latest ON (
                (pm.sender = @number AND pm.receiver = latest.contact_number) OR
                (pm.receiver = @number AND pm.sender = latest.contact_number)
            ) AND pm.sent_at = latest.max_sent_at
            ORDER BY pm.sent_at DESC
        ]], {
            ['@number'] = phoneNumber
        }, function(conversations)
            TriggerClientEvent('phone:receiveConversations', src, conversations)
        end)
    end
end)

-- Get contacts
RegisterNetEvent('phone:getContacts')
AddEventHandler('phone:getContacts', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if phoneNumber then
        MySQL.Async.fetchAll('SELECT * FROM phone_contacts WHERE owner = @owner ORDER BY contact_name ASC LIMIT @limit', {
            ['@owner'] = phoneNumber,
            ['@limit'] = Config.MaxContacts
        }, function(contacts)
            TriggerClientEvent('phone:receiveContacts', src, contacts)
        end)
    end
end)

-- Add contact
RegisterNetEvent('phone:addContact')
AddEventHandler('phone:addContact', function(contactNumber, contactName)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if not phoneNumber then
        TriggerClientEvent('phone:notify', src, 'Error: You do not have a phone number')
        return
    end
    
    if not contactNumber or not contactName or contactNumber == '' or contactName == '' then
        TriggerClientEvent('phone:notify', src, 'Please enter both a number and a name')
        return
    end
    
    -- Sanitize input length
    if #contactName > 50 then
        contactName = string.sub(contactName, 1, 50)
    end
    
    MySQL.Async.execute('INSERT INTO phone_contacts (owner, contact_number, contact_name) VALUES (@owner, @number, @name) ON DUPLICATE KEY UPDATE contact_name = @name', {
        ['@owner'] = phoneNumber,
        ['@number'] = contactNumber,
        ['@name'] = contactName
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('phone:notify', src, 'Contact saved')
            TriggerClientEvent('phone:contactSaved', src, contactNumber, contactName)
        else
            TriggerClientEvent('phone:notify', src, 'Failed to save contact')
        end
    end)
end)

-- Delete contact
RegisterNetEvent('phone:deleteContact')
AddEventHandler('phone:deleteContact', function(contactId)
    local src = source
    local identifier = GetPlayerIdentifier(src, 0)
    local phoneNumber = phoneNumbers[identifier]
    
    if phoneNumber then
        MySQL.Async.execute('DELETE FROM phone_contacts WHERE id = @id AND owner = @owner', {
            ['@id'] = contactId,
            ['@owner'] = phoneNumber
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('phone:notify', src, 'Contact deleted')
                -- Refresh contacts list
                TriggerServerEvent('phone:getContacts')
            end
        end)
    end
end)

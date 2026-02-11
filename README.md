# CSRP Phone - Standalone Phone System for FiveM

A complete standalone phone system for FiveM servers with integrated PMA Voice support, texting, call history, and automatic phone number assignment.

## Features

✅ **Phone Calls**
- Make and receive phone calls with PMA Voice integration
- Call waiting and busy line detection
- Call duration tracking
- Incoming call notifications with ringtone

✅ **Text Messaging**
- Send and receive text messages
- Conversation threads
- Message history
- Real-time message notifications

✅ **Call History**
- Complete call logs (incoming, outgoing, missed)
- Call duration tracking
- Click to call back from history

✅ **Automatic Phone Numbers**
- Automatic assignment on first join
- Persistent phone numbers stored in database
- Unique number generation

✅ **Database Integration**
- MySQL/MariaDB support via mysql-async
- Stores phone numbers, messages, and call history
- Efficient data management

## Requirements

- FiveM Server
- [mysql-async](https://github.com/brouznouf/fivem-mysql-async) resource
- [pma-voice](https://github.com/AvarianKnight/pma-voice) resource

## Installation

1. **Download and Extract**
   - Download the resource
   - Extract to your server's `resources` folder
   - Rename folder to `CSRP-Phone`

2. **Database Setup**
   - Import `phone.sql` into your MySQL/MariaDB database
   - This will create three tables:
     - `phone_numbers` - Player phone numbers
     - `phone_messages` - Text messages
     - `phone_calls` - Call history

3. **Configuration**
   - Open `config.lua` and adjust settings as needed
   - Default settings work with most servers

4. **Server Configuration**
   - Add to your `server.cfg`:
   ```
   ensure mysql-async
   ensure pma-voice
   ensure CSRP-Phone
   ```

5. **Start Server**
   - Restart your server or start the resource
   - Players will automatically receive phone numbers on join

## Usage

### Opening the Phone
- Press **F1** (default) or use command `/phone`
- Can be configured in `config.lua`

### Making Calls
1. Open phone
2. Click "Call" icon
3. Enter phone number
4. Click "Call" button

### Sending Messages
1. Open phone
2. Click "Messages" icon
3. Click "New Message"
4. Enter phone number and message
5. Click "Send"

### Viewing Call History
1. Open phone
2. Click "History" icon
3. Click any call to call back

## Configuration

Edit `config.lua` to customize:

```lua
-- Phone number format
Config.PhoneNumberPrefix = "555"  -- Prefix for all numbers
Config.PhoneNumberLength = 7      -- Length of phone numbers

-- Controls
Config.OpenPhoneCommand = "phone" -- Command to open phone
Config.OpenPhoneKey = 288         -- Key to open phone (F1)

-- PMA Voice
Config.CallChannel = 1000         -- Starting channel for calls
Config.MaxCallDistance = 1000.0   -- Max distance for call quality

-- Call settings
Config.CallRingTime = 30000       -- Ring time before timeout (ms)

-- Messages
Config.MaxMessageLength = 250     -- Max characters per message
```

## Database Structure

### phone_numbers
- `id` - Auto increment ID
- `identifier` - Player identifier (steam, license, etc.)
- `phone_number` - Player's phone number
- `created_at` - Timestamp

### phone_messages
- `id` - Auto increment ID
- `sender` - Sender's phone number
- `receiver` - Receiver's phone number
- `message` - Message content
- `sent_at` - Timestamp
- `is_read` - Read status

### phone_calls
- `id` - Auto increment ID
- `caller` - Caller's phone number
- `receiver` - Receiver's phone number
- `duration` - Call duration in seconds
- `call_time` - Timestamp
- `call_type` - Type: incoming, outgoing, or missed

## API / Events

### Client Events

**Trigger Server Events:**
```lua
TriggerServerEvent('phone:getPhoneNumber')
TriggerServerEvent('phone:startCall', targetNumber)
TriggerServerEvent('phone:acceptCall', callerNumber)
TriggerServerEvent('phone:declineCall', callerNumber)
TriggerServerEvent('phone:endCall')
TriggerServerEvent('phone:sendMessage', targetNumber, message)
TriggerServerEvent('phone:getCallHistory')
TriggerServerEvent('phone:getMessages', contactNumber)
```

**Receive from Server:**
```lua
RegisterNetEvent('phone:receivePhoneNumber')
RegisterNetEvent('phone:incomingCall')
RegisterNetEvent('phone:callAccepted')
RegisterNetEvent('phone:callEnded')
RegisterNetEvent('phone:receiveMessage')
RegisterNetEvent('phone:notify')
```

### Server Events

**Register Events:**
```lua
RegisterNetEvent('phone:getPhoneNumber')
RegisterNetEvent('phone:startCall')
RegisterNetEvent('phone:acceptCall')
RegisterNetEvent('phone:declineCall')
RegisterNetEvent('phone:endCall')
RegisterNetEvent('phone:sendMessage')
RegisterNetEvent('phone:getCallHistory')
RegisterNetEvent('phone:getMessages')
```

## Troubleshooting

**Phone numbers not generating:**
- Check mysql-async is running
- Verify database tables exist
- Check server console for errors

**Calls not working:**
- Ensure pma-voice is installed and running
- Check that both players have phone numbers
- Verify PMA Voice configuration

**Messages not sending:**
- Check database connection
- Verify both phone numbers exist
- Check server console for errors

**UI not showing:**
- Clear FiveM cache
- Check browser console (F8) for errors
- Verify all HTML files are present

## Credits

- **Author:** CSRP Development
- **PMA Voice:** AvarianKnight
- **mysql-async:** brouznouf

## License

This resource is free to use and modify for your FiveM server.

## Support

For issues or questions:
1. Check troubleshooting section
2. Review server console logs
3. Verify all requirements are met
4. Check configuration settings

## Changelog

### Version 1.0.0
- Initial release
- Phone call system with PMA Voice
- Text messaging system
- Call history tracking
- Automatic phone number assignment
- Database integration
- Modern UI design

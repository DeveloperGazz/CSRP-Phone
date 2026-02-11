Config = {}

-- Phone number settings
Config.PhoneNumberPrefix = "0"    -- Prefix for all phone numbers (format: 0xxxxxxxxxx)
Config.PhoneNumberLength = 10     -- Number of random digits after prefix (total length: 11 including prefix)

-- Command settings
Config.OpenPhoneCommand = "phone" -- Command to open phone
Config.OpenPhoneKey = 288         -- F1 key to open phone (change as needed)

-- PMA Voice settings
Config.CallChannel = 1000         -- Starting channel for phone calls
Config.MaxCallDistance = 1000.0   -- Maximum distance for call quality

-- Notification settings
Config.NotificationTime = 5000    -- Time in ms to show notifications

-- Call settings
Config.EnableCallWaiting = true   -- Allow call waiting
Config.CallRingTime = 30000       -- Time in ms before call times out (30 seconds)

-- Text message settings
Config.MaxMessageLength = 250     -- Maximum characters in a text message
Config.MessageCost = 0            -- Cost per text message (0 = free)

-- Call history settings
Config.MaxCallHistory = 50        -- Maximum number of calls to store per player
Config.MaxMessageHistory = 100    -- Maximum number of messages to store per player

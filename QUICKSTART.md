# Quick Start Guide - CSRP Phone

Get your phone system up and running in 5 minutes!

## Prerequisites Checklist

Before you start, make sure you have:
- [ ] FiveM server running
- [ ] MySQL/MariaDB database
- [ ] mysql-async resource installed
- [ ] pma-voice resource installed

## Installation Steps

### Step 1: Database Setup (2 minutes)
1. Open your database management tool (phpMyAdmin, HeidiSQL, etc.)
2. Select your FiveM database
3. Import the `phone.sql` file from the CSRP-Phone folder
4. Verify 3 tables were created:
   - `phone_numbers`
   - `phone_messages`
   - `phone_calls`

### Step 2: File Installation (1 minute)
1. Copy the `CSRP-Phone` folder to your `resources` directory
2. Example path: `/server-data/resources/CSRP-Phone/`

### Step 3: Server Configuration (1 minute)
1. Open your `server.cfg` file
2. Add these lines (in order):
   ```cfg
   ensure mysql-async
   ensure pma-voice
   ensure CSRP-Phone
   ```

### Step 4: Restart Server (1 minute)
1. Save `server.cfg`
2. Restart your FiveM server
3. Watch console for: `"Loaded X phone numbers"`
4. If you see errors, check troubleshooting below

## First Use

### For Players:
1. Join your server
2. Press **F1** to open phone (or type `/phone`)
3. Your phone number will be displayed at the top
4. Try it out:
   - Click **Call** to make a call
   - Click **Messages** to send texts
   - Click **History** to see call logs

### Testing Between Two Players:
1. **Player 1**: Open phone, note your number
2. **Player 2**: Open phone, go to Call
3. **Player 2**: Enter Player 1's number and click Call
4. **Player 1**: Accept the incoming call
5. **Both**: You should now hear each other via PMA Voice!

## Common Issues & Fixes

### ❌ "Resource failed to start"
**Fix:** 
- Check console for specific error
- Verify mysql-async and pma-voice are running
- Run `ensure CSRP-Phone` in console

### ❌ "No phone number assigned"
**Fix:**
- Check database tables exist
- Verify mysql-async connection
- Rejoin the server

### ❌ "Phone UI not showing"
**Fix:**
- Press F1 or type `/phone`
- Check F8 console for errors
- Clear FiveM cache

### ❌ "Calls don't connect"
**Fix:**
- Verify pma-voice is working
- Check both players have phone numbers
- Try restarting the resource

## Customization

Want to customize? Edit `config.lua`:

```lua
-- Change phone number format
Config.PhoneNumberPrefix = "555"

-- Change open key (default F1)
Config.OpenPhoneKey = 288

-- Change ring time (milliseconds)
Config.CallRingTime = 30000
```

## What's Next?

- Read [INSTALL.md](INSTALL.md) for detailed installation
- Read [FEATURES.md](FEATURES.md) for all features
- Read [API_EXAMPLES.md](API_EXAMPLES.md) for integrations
- Read [README.md](README.md) for complete documentation

## Need Help?

1. Check the [INSTALL.md](INSTALL.md) troubleshooting section
2. Review server console for errors
3. Check client F8 console for errors
4. Verify all prerequisites are met

## Pro Tips

💡 **For Server Admins:**
- Phone numbers are auto-generated on first join
- All data persists in database
- You can manually change numbers in the database
- Works with ESX, QBCore, or standalone

💡 **For Players:**
- Share your number with friends in RP
- Use for realistic business communications
- Check history to return missed calls
- Messages are saved and available anytime

💡 **For Developers:**
- See API_EXAMPLES.md for integration
- Easy to add custom apps to the phone
- Event-based architecture for extensions
- Full access to database tables

## Success Indicators

✅ Server starts without errors  
✅ Console shows "Loaded X phone numbers"  
✅ Players can open phone with F1  
✅ Phone numbers are displayed  
✅ Calls connect and voice works  
✅ Messages send and receive  
✅ History shows call logs  

If all checks pass, you're good to go! 🎉

## Support

For issues:
1. Review this guide
2. Check documentation
3. Verify prerequisites
4. Check server/client logs

---

**Happy Role-Playing!** 📱

Made with ❤️ by CSRP Development

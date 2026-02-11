# Quick Installation Guide

## Prerequisites
Before installing CSRP-Phone, make sure you have:
- A FiveM server (Windows or Linux)
- MySQL or MariaDB database
- mysql-async resource installed
- pma-voice resource installed

## Step-by-Step Installation

### 1. Download and Place Files
```
1. Download the CSRP-Phone folder
2. Place it in your server's resources folder
   Example: /server-data/resources/CSRP-Phone/
```

### 2. Database Setup
```
1. Open your MySQL/MariaDB database management tool (phpMyAdmin, HeidiSQL, etc.)
2. Select your FiveM database
3. Import the phone.sql file
   - This creates 3 tables: phone_numbers, phone_messages, phone_calls
4. Verify tables were created successfully
```

### 3. Configure Dependencies
Make sure these resources are in your server.cfg BEFORE CSRP-Phone:
```cfg
ensure mysql-async
ensure pma-voice
```

### 4. Add Resource to server.cfg
Add this line to your server.cfg:
```cfg
ensure CSRP-Phone
```

Your server.cfg should look like:
```cfg
# Database
ensure mysql-async

# Voice
ensure pma-voice

# Phone System
ensure CSRP-Phone

# ... other resources
```

### 5. Optional Configuration
Edit `config.lua` if you want to customize:
- Phone number format
- Key bindings
- Call settings
- Message settings

### 6. Start/Restart Server
```
1. Save server.cfg
2. Restart your FiveM server
3. Check console for any errors
4. Look for: "Loaded X phone numbers" message
```

## Testing

### Test 1: Phone Number Assignment
```
1. Join the server
2. Type /phone or press F1
3. Check if you have a phone number displayed
```

### Test 2: Calling
```
1. Have two players on the server
2. Player 1 opens phone, goes to Call
3. Enter Player 2's number and call
4. Player 2 should receive incoming call
5. Accept and verify voice works
```

### Test 3: Texting
```
1. Player 1 opens phone, goes to Messages
2. Click New Message
3. Enter Player 2's number and message
4. Player 2 should receive notification
5. Check conversation in Messages
```

### Test 4: Call History
```
1. Make a few calls between players
2. Open phone, go to History
3. Verify all calls are logged
4. Check call types (incoming/outgoing/missed)
```

## Troubleshooting

### Issue: Phone doesn't open
**Solution:**
- Check console for errors
- Verify resource started (type `ensure CSRP-Phone` in console)
- Try `/phone` command instead of F1

### Issue: No phone number assigned
**Solution:**
- Check mysql-async is running
- Verify database tables exist
- Check database connection in mysql-async config
- Look for errors in server console

### Issue: Calls don't work
**Solution:**
- Ensure pma-voice is installed and working
- Test normal voice first
- Check both players have phone numbers
- Verify no errors in F8 console

### Issue: Messages don't send
**Solution:**
- Check database connection
- Verify phone numbers exist for both players
- Check server console for SQL errors
- Test with shorter messages first

### Issue: UI not showing
**Solution:**
- Clear FiveM cache (delete FiveM Application Data)
- Check F8 console for JavaScript errors
- Verify all HTML files are present
- Restart FiveM client

## Common Questions

**Q: Can I change phone numbers?**
A: Yes, directly in the database. Update the `phone_numbers` table.

**Q: How do I reset all phone numbers?**
A: Run: `TRUNCATE TABLE phone_numbers;` in your database.

**Q: Can players see each other's numbers?**
A: No, phone numbers are private. Players must share them manually.

**Q: Does this work with ESX/QBCore?**
A: Yes, it's standalone and works with any framework.

**Q: Can I customize the UI?**
A: Yes, edit files in the `html/` folder.

## Support

If you encounter issues:
1. Check server console for errors
2. Check client F8 console for errors
3. Verify all prerequisites are met
4. Review this guide again
5. Check the main README.md for more details

## Performance

This resource is optimized for performance:
- Minimal client-side threads
- Efficient database queries
- NUI only active when phone is open
- No constant loops or ticks

Expected impact: < 0.01ms on both client and server

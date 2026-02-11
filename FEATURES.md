# CSRP-Phone Feature Overview

## 📱 Complete Phone System

### Core Features

#### 🔢 Automatic Phone Number Assignment
- Every player gets a unique phone number automatically when they join
- Phone numbers are saved to database permanently
- Format: `555-XXXXXXX` (customizable)
- No manual assignment needed

#### 📞 Voice Calling with PMA Voice
- Make calls to any phone number
- Integration with PMA Voice for crystal clear communication
- Call status indicators (calling, ringing, in call)
- Call duration tracking
- Busy line detection
- Call waiting support
- Auto-timeout for unanswered calls (30 seconds default)

#### 💬 Text Messaging
- Send and receive text messages
- Conversation threads with contacts
- Message history saved to database
- Real-time message notifications
- Character limit (250 default)
- Message timestamps
- Read/unread status

#### 📋 Call History
- Complete call logs
- Three types: Incoming, Outgoing, Missed
- Shows call duration
- Timestamps for all calls
- Click to call back from history
- Color-coded call types

### User Interface

#### Modern & Intuitive Design
- Sleek gradient design (purple theme)
- Mobile phone appearance
- Easy navigation
- Responsive buttons
- Smooth animations
- Clean typography

#### Navigation
- **Home Screen**: App icons for Call, Messages, History
- **Call Screen**: Dialpad to enter numbers and call
- **Messages Screen**: View all conversations
- **New Message**: Send text to any number
- **Conversation View**: Chat-style message display
- **Call History**: List of all calls with details
- **Active Call Screen**: Shows when in a call

### Technical Features

#### Database Integration
- MySQL/MariaDB support
- Three main tables:
  - `phone_numbers`: Player phone numbers
  - `phone_messages`: All text messages
  - `phone_calls`: Complete call logs
- Automatic data persistence
- Efficient queries for performance

#### PMA Voice Integration
- Seamless voice channel switching
- Private call channels
- No interference with normal voice
- Automatic channel cleanup
- Distance-independent calling

#### Performance Optimized
- Minimal resource usage
- NUI only active when phone is open
- No constant loops
- Efficient event handling
- < 0.01ms average impact

### Controls

#### Opening the Phone
- Default: Press **F1** key
- Alternative: Type `/phone` command
- Customizable in config

#### Using the Phone
- Click app icons to open apps
- Click back buttons to navigate
- Click X to close phone
- Press ESC to close phone

### Configuration Options

All configurable in `config.lua`:

```lua
-- Phone number format
PhoneNumberPrefix = "555"
PhoneNumberLength = 7

-- Controls
OpenPhoneCommand = "phone"
OpenPhoneKey = 288 (F1)

-- PMA Voice settings
CallChannel = 1000
MaxCallDistance = 1000.0

-- Call settings
CallRingTime = 30000 (30 seconds)
EnableCallWaiting = true

-- Message settings
MaxMessageLength = 250
MessageCost = 0 (free)

-- History limits
MaxCallHistory = 50
MaxMessageHistory = 100
```

### Installation Requirements

1. **FiveM Server** (any version)
2. **mysql-async** resource
3. **pma-voice** resource
4. **MySQL/MariaDB** database

### Use Cases

#### Role-Play Scenarios
- Emergency services (911, EMS, Police)
- Business communications
- Criminal operations coordination
- Social interactions
- Taxi/delivery services
- Real estate agents
- Legal consultations
- News reporting

#### Server Features
- Player-to-player communication
- System notifications via SMS
- Job dispatching
- Event coordination
- Gang/organization communication
- Trading and sales
- Dating and social RP

### Security & Privacy

- Phone numbers are unique per player
- No cross-talk between calls
- Private conversations
- Secure database storage
- No phone number leaks

### Compatibility

- ✅ Works with ESX
- ✅ Works with QBCore
- ✅ Works with VRP
- ✅ Works standalone (no framework needed)
- ✅ Compatible with all maps
- ✅ Compatible with other phone scripts (standalone)

### Future-Proof Design

- Easy to extend with new apps
- Modifiable UI (HTML/CSS/JS)
- Clear API for integration
- Well-documented code
- Active maintenance support

### What Makes It Different?

1. **Truly Standalone**: No framework dependencies
2. **Complete Package**: Calls, texts, history all included
3. **PMA Voice Native**: Built specifically for PMA Voice
4. **Auto Phone Numbers**: Zero admin work needed
5. **Modern UI**: Beautiful, user-friendly interface
6. **Database Backed**: Everything is saved permanently
7. **Performance Focused**: Minimal impact on server
8. **Easy Install**: 5-minute setup
9. **Well Documented**: Complete guides and examples
10. **Free & Open**: Use and modify freely

### System Requirements

**Server:**
- Windows or Linux FiveM server
- MySQL 5.7+ or MariaDB 10.0+
- 50MB free disk space
- mysql-async resource
- pma-voice resource

**Client:**
- Standard FiveM client
- Any modern PC that runs FiveM
- No additional downloads needed

### Support & Documentation

- README.md - Complete feature documentation
- INSTALL.md - Step-by-step installation guide
- API_EXAMPLES.md - Integration examples
- Inline code comments
- Configuration examples

---

**Version:** 1.0.0  
**Author:** CSRP Development  
**License:** Free to use and modify  
**Repository:** DeveloperGazz/CSRP-Phone

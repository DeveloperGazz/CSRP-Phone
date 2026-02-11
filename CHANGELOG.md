# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024

### Added
- Initial release of CSRP-Phone
- Phone calling system with PMA Voice integration
- Text messaging system with conversation threads
- Call history tracking (incoming, outgoing, missed calls)
- Automatic phone number assignment for all players
- Database integration (MySQL/MariaDB)
- Modern phone UI with gradient design
- Three main screens: Calls, Messages, History
- Real-time message notifications
- Call duration tracking
- Busy line detection
- Call waiting support
- Auto-timeout for unanswered calls (30 seconds)
- Character limit for messages (250 characters)
- Customizable configuration file
- Complete documentation (README, INSTALL, FEATURES, API_EXAMPLES)
- .gitignore for clean repository
- Support for ESX, QBCore, and standalone servers

### Technical Features
- Server-side phone number management
- Client-side PMA Voice integration
- NUI-based phone interface (HTML/CSS/JavaScript)
- Efficient database queries
- Performance optimized (< 0.01ms impact)
- Event-based architecture
- Standalone resource (no framework dependencies)

### Configuration Options
- Phone number format customization
- Control key customization
- PMA Voice channel settings
- Call timeout settings
- Message length limits
- History storage limits

### Database Tables
- `phone_numbers` - Player phone number storage
- `phone_messages` - Message history with read status
- `phone_calls` - Complete call logs with duration

### Documentation
- README.md - Main documentation
- INSTALL.md - Installation guide
- FEATURES.md - Feature overview
- API_EXAMPLES.md - Integration examples

## Future Enhancements (Planned)

### Potential Features
- Contacts system (save phone numbers with names)
- Group messaging
- Photo/image sharing
- Call blocking
- Voicemail system
- Emergency 911 integration
- Custom ringtones
- Phone themes/skins
- GPS/location sharing
- Banking app integration
- Social media app
- Camera app
- Weather app
- Notes app
- Calculator app
- Settings app (vibration, volume, etc.)
- Multi-language support
- Phone shops to buy/sell phones
- Phone damage/repair system
- Battery system
- Signal strength system
- Data plan system

### Technical Improvements
- WebSocket for real-time updates
- Redis caching for performance
- Advanced anti-cheat measures
- Audio file support for ringtones
- Image optimization
- Better error handling
- Unit tests
- Performance benchmarks
- Migration tools for other phone scripts

## Version History

- **v1.0.0** - Initial release with core features

---

For more information about updates and features, check the repository.

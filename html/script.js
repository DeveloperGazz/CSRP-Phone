let myPhoneNumber = null;
let currentConversation = null;
let callHistory = [];
let conversations = [];
let messages = [];
let clockInterval = null;
let contacts = [];
let isOnHold = false;
let isSpeakerOn = false;

// Update status bar time
function updateStatusTime() {
    const now = new Date();
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const el = document.getElementById('status-time');
    if (el) {
        el.textContent = hours + ':' + minutes;
    }
}

// Listen for messages from client
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'togglePhone':
            togglePhone(data.show);
            break;
        case 'setPhoneNumber':
            setPhoneNumber(data.phoneNumber);
            break;
        case 'openScreen':
            openApp(data.screen);
            break;
        case 'incomingCall':
            showIncomingCall(data.phoneNumber);
            break;
        case 'outgoingCall':
            showOutgoingCall(data.phoneNumber);
            break;
        case 'callAccepted':
            showActiveCall(data.phoneNumber);
            break;
        case 'callDeclined':
            showCallDeclined();
            break;
        case 'callEnded':
            endCall();
            break;
        case 'callMissed':
            endCall();
            break;
        case 'updateCallDuration':
            updateCallDuration(data.duration);
            break;
        case 'receiveMessage':
            receiveMessage(data.phoneNumber, data.message);
            break;
        case 'messageSent':
            onMessageSent(data.phoneNumber, data.message);
            break;
        case 'receiveCallHistory':
            displayCallHistory(data.calls, data.myNumber);
            break;
        case 'receiveMessages':
            displayMessages(data.messages, data.myNumber);
            break;
        case 'receiveConversations':
            displayConversations(data.conversations);
            break;
        case 'receiveContacts':
            displayContacts(data.contacts);
            break;
        case 'contactSaved':
            onContactSaved(data.contactNumber, data.contactName);
            break;
        case 'lineBusy':
            showLineBusy(data.phoneNumber);
            break;
    }
});

function togglePhone(show) {
    const container = document.getElementById('phone-container');
    if (show) {
        container.classList.remove('hidden');
        updateStatusTime();
        if (!clockInterval) {
            clockInterval = setInterval(updateStatusTime, 10000);
        }
        openApp('home');
    } else {
        container.classList.add('hidden');
        if (clockInterval) {
            clearInterval(clockInterval);
            clockInterval = null;
        }
    }
}

function setPhoneNumber(number) {
    myPhoneNumber = number;
    document.getElementById('phone-number').textContent = number;
}

function openApp(appName) {
    // Hide all screens
    const screens = document.querySelectorAll('.screen');
    screens.forEach(screen => screen.classList.remove('active'));
    
    // Show selected screen
    const screen = document.getElementById(appName + '-screen');
    if (screen) {
        screen.classList.add('active');
    }
}

function closePhone() {
    const container = document.getElementById('phone-container');
    container.classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closePhone`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function makeCall() {
    const phoneNumber = document.getElementById('call-number-input').value.trim();
    if (phoneNumber) {
        fetch(`https://${GetParentResourceName()}/startCall`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({phoneNumber: phoneNumber})
        });
        document.getElementById('call-number-input').value = '';
    }
}

function showIncomingCall(phoneNumber) {
    const displayName = getContactName(phoneNumber);
    document.getElementById('incoming-caller-number').textContent = displayName;
    openApp('incoming-call');
}

function showOutgoingCall(phoneNumber) {
    const displayName = getContactName(phoneNumber);
    document.getElementById('outgoing-caller-number').textContent = displayName;
    openApp('outgoing-call');
}

function showActiveCall(phoneNumber) {
    const displayName = getContactName(phoneNumber);
    document.getElementById('active-caller-number').textContent = displayName;
    document.getElementById('call-duration').textContent = '00:00';
    openApp('active-call');
}

function acceptCall() {
    fetch(`https://${GetParentResourceName()}/acceptCall`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function declineCall() {
    fetch(`https://${GetParentResourceName()}/declineCall`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    openApp('home');
}

function endCall() {
    // Reset call control states
    isOnHold = false;
    isSpeakerOn = false;
    const holdBtn = document.getElementById('btn-hold');
    const speakerBtn = document.getElementById('btn-speaker');
    if (holdBtn) {
        holdBtn.classList.remove('active');
        holdBtn.querySelector('p').textContent = 'Hold';
    }
    if (speakerBtn) {
        speakerBtn.classList.remove('active');
    }
    
    fetch(`https://${GetParentResourceName()}/endCall`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    openApp('home');
}

function showCallDeclined() {
    openApp('home');
}

function updateCallDuration(seconds) {
    const minutes = Math.floor(seconds / 60);
    const secs = seconds % 60;
    const timeString = `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    document.getElementById('call-duration').textContent = timeString;
}

function sendMessage() {
    const phoneNumber = document.getElementById('message-number-input').value.trim();
    const message = document.getElementById('message-text-input').value.trim();
    
    if (phoneNumber && message) {
        fetch(`https://${GetParentResourceName()}/sendMessage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                phoneNumber: phoneNumber,
                message: message
            })
        });
        
        document.getElementById('message-number-input').value = '';
        document.getElementById('message-text-input').value = '';
    }
}

function replyMessage() {
    const message = document.getElementById('reply-text-input').value.trim();
    
    if (currentConversation && message) {
        fetch(`https://${GetParentResourceName()}/sendMessage`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                phoneNumber: currentConversation,
                message: message
            })
        });
        
        // Add message to UI immediately
        addMessageToConversation(message, true);
        document.getElementById('reply-text-input').value = '';
    }
}

function receiveMessage(phoneNumber, message) {
    // If we're viewing this conversation, add it to the display
    if (currentConversation === phoneNumber) {
        addMessageToConversation(message, false);
    }
    
    // Refresh conversations list
    setTimeout(() => {
        fetch(`https://${GetParentResourceName()}/getMessages`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({contactNumber: currentConversation})
        });
    }, 100);
}

function onMessageSent(phoneNumber, message) {
    // Refresh conversations list
    fetch(`https://${GetParentResourceName()}/getMessages`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({contactNumber: phoneNumber})
    });
    openConversation(phoneNumber);
}

function displayConversations(convos) {
    conversations = convos;
    const list = document.getElementById('conversations-list');
    list.innerHTML = '';
    
    if (convos.length === 0) {
        list.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No messages yet</p>';
        return;
    }
    
    convos.forEach(convo => {
        const item = document.createElement('div');
        item.className = 'conversation-item';
        item.onclick = () => openConversation(convo.contact);
        
        item.innerHTML = `
            <div class="contact-number">${getContactName(convo.contact)}</div>
            <div class="last-message">${convo.message}</div>
        `;
        
        list.appendChild(item);
    });
}

function openConversation(phoneNumber) {
    currentConversation = phoneNumber;
    document.getElementById('conversation-contact').textContent = phoneNumber;
    
    // Request messages for this contact
    fetch(`https://${GetParentResourceName()}/getMessages`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({contactNumber: phoneNumber})
    });
    
    openApp('conversation');
}

function displayMessages(msgs, myNumber) {
    messages = msgs;
    const list = document.getElementById('messages-list');
    list.innerHTML = '';
    
    if (msgs.length === 0) {
        list.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No messages yet</p>';
        return;
    }
    
    // Display messages in chronological order (oldest first)
    msgs.reverse().forEach(msg => {
        const isSent = msg.sender === myNumber;
        addMessageToConversation(msg.message, isSent, msg.sent_at);
    });
    
    // Scroll to bottom
    list.scrollTop = list.scrollHeight;
}

function addMessageToConversation(message, isSent, timestamp) {
    const list = document.getElementById('messages-list');
    const item = document.createElement('div');
    item.className = `message-item ${isSent ? 'sent' : 'received'}`;
    
    let timeString = '';
    if (timestamp) {
        const date = new Date(timestamp);
        timeString = date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
    } else {
        const now = new Date();
        timeString = now.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
    }
    
    item.innerHTML = `
        <div>${message}</div>
        <div class="message-time">${timeString}</div>
    `;
    
    list.appendChild(item);
    list.scrollTop = list.scrollHeight;
}

function displayCallHistory(calls, myNumber) {
    callHistory = calls;
    const list = document.getElementById('call-history-list');
    list.innerHTML = '';
    
    if (calls.length === 0) {
        list.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No call history</p>';
        return;
    }
    
    calls.forEach(call => {
        const item = document.createElement('div');
        item.className = 'call-item';
        
        // Determine the other party's number
        const otherNumber = call.caller === myNumber ? call.receiver : call.caller;
        const displayName = getContactName(otherNumber);
        
        // Format duration
        let durationText = 'Not answered';
        if (call.duration > 0) {
            const minutes = Math.floor(call.duration / 60);
            const seconds = call.duration % 60;
            durationText = `${minutes}m ${seconds}s`;
        }
        
        // Format time
        const date = new Date(call.call_time);
        const timeString = date.toLocaleString();
        
        item.innerHTML = `
            <div class="contact-number">${displayName}</div>
            <div class="call-info">
                <span class="call-type ${call.call_type}">${call.call_type}</span>
                <span>${durationText}</span>
            </div>
            <div style="font-size: 12px; color: #999; margin-top: 5px;">${timeString}</div>
        `;
        
        // Make it clickable to call back
        item.onclick = () => {
            document.getElementById('call-number-input').value = otherNumber;
            openApp('contacts');
        };
        
        list.appendChild(item);
    });
}

function GetParentResourceName() {
    return window.location.hostname;
}

// ===== Contacts Functions =====

function saveContact() {
    const name = document.getElementById('contact-name-input').value.trim();
    const number = document.getElementById('contact-number-input').value.trim();
    
    if (name && number) {
        fetch(`https://${GetParentResourceName()}/addContact`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ contactName: name, contactNumber: number })
        });
        document.getElementById('contact-name-input').value = '';
        document.getElementById('contact-number-input').value = '';
    }
}

function deleteContact(contactId) {
    fetch(`https://${GetParentResourceName()}/deleteContact`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contactId: contactId })
    });
}

function displayContacts(contactList) {
    contacts = contactList;
    const list = document.getElementById('contacts-list');
    list.innerHTML = '';
    
    if (contactList.length === 0) {
        list.innerHTML = '<p style="text-align: center; color: #999; padding: 20px;">No contacts yet</p>';
        return;
    }
    
    contactList.forEach(contact => {
        const item = document.createElement('div');
        item.className = 'contact-item';
        
        item.innerHTML = `
            <div class="contact-item-info">
                <div class="contact-item-name">${contact.contact_name}</div>
                <div class="contact-item-number">${contact.contact_number}</div>
            </div>
            <div class="contact-item-actions">
                <button class="contact-action-btn call" onclick="event.stopPropagation(); callContact('${contact.contact_number}')">📞</button>
                <button class="contact-action-btn message" onclick="event.stopPropagation(); messageContact('${contact.contact_number}')">💬</button>
                <button class="contact-action-btn delete" onclick="event.stopPropagation(); deleteContact(${contact.id})">🗑</button>
            </div>
        `;
        
        list.appendChild(item);
    });
}

function onContactSaved(contactNumber, contactName) {
    // Refresh contacts list
    fetch(`https://${GetParentResourceName()}/getContacts`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
    openApp('addressbook');
}

function callContact(phoneNumber) {
    fetch(`https://${GetParentResourceName()}/startCall`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ phoneNumber: phoneNumber })
    });
}

function messageContact(phoneNumber) {
    openConversation(phoneNumber);
}

function getContactName(phoneNumber) {
    const contact = contacts.find(c => c.contact_number === phoneNumber);
    return contact ? contact.contact_name : phoneNumber;
}

function showLineBusy(phoneNumber) {
    const displayName = getContactName(phoneNumber);
    document.getElementById('busy-caller-number').textContent = displayName;
    openApp('busy');
}

function toggleHold() {
    isOnHold = !isOnHold;
    const btn = document.getElementById('btn-hold');
    if (isOnHold) {
        btn.classList.add('active');
        btn.querySelector('p').textContent = 'Resume';
    } else {
        btn.classList.remove('active');
        btn.querySelector('p').textContent = 'Hold';
    }
}

function toggleSpeaker() {
    isSpeakerOn = !isSpeakerOn;
    const btn = document.getElementById('btn-speaker');
    if (isSpeakerOn) {
        btn.classList.add('active');
    } else {
        btn.classList.remove('active');
    }
}

// Handle ESC key to close phone
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closePhone();
    }
});

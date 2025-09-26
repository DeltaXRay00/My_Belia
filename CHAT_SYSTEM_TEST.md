# Chat System Test Script
# This script demonstrates how to test the chat system

# 1. Start the Phoenix server
# mix phx.server

# 2. Open two browser tabs:
# Tab 1: http://localhost:4000/log-masuk (Login as user)
# Tab 2: http://localhost:4000/log-masuk (Login as admin)

# 3. Test the chat system:

# For User:
# - Go to http://localhost:4000/chat
# - You should see "Tiada perbualan chat" (No chat conversations)

# For Admin:
# - Go to http://localhost:4000/admin/chat  
# - You should see "Tiada perbualan chat" (No chat conversations)

# 4. Create a test conversation:
# - Admin goes to http://localhost:4000/admin/khidmat_pengguna
# - Admin creates a conversation from a contact message
# - User will then see the conversation in their chat

# 5. Test messaging:
# - User sends a message
# - Admin sees the message in their chat
# - Admin responds
# - User sees the response

# Routes available:
# User Chat: /chat
# Admin Chat: /admin/chat
# Contact Messages: /admin/khidmat_pengguna
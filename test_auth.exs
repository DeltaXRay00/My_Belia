# Test authentication
IO.puts("Testing authentication...")

# Check if user exists
user = MyBelia.Accounts.get_user_by_email("admin@mybelia.gov.my")
IO.inspect(user, label: "User from database")

if user do
  IO.puts("User found: #{user.email}")
  IO.puts("Password hash: #{String.slice(user.password_hash, 0, 20)}...")
  
  # Test password verification
  result = MyBelia.Accounts.User.verify_password("ABC#xyz00!", user.password_hash)
  IO.inspect(result, label: "Password verification result")
  
  # Test full authentication
  auth_result = MyBelia.Accounts.authenticate_user("admin@mybelia.gov.my", "ABC#xyz00!")
  IO.inspect(auth_result, label: "Full authentication result")
else
  IO.puts("User not found!")
end

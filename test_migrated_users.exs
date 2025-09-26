# Test authentication for migrated users
IO.puts("Testing authentication for migrated users...")

# Test Kevin@mybelia.com (admin)
IO.puts("Testing Kevin@mybelia.com (admin)...")
auth_result = MyBelia.Accounts.authenticate_user("Kevin@mybelia.com", "TempPassword123!")
IO.inspect(auth_result, label: "Kevin authentication")

# Test admin@mybelia.com (admin)
IO.puts("Testing admin@mybelia.com (admin)...")
auth_result2 = MyBelia.Accounts.authenticate_user("admin@mybelia.com", "TempPassword123!")
IO.inspect(auth_result2, label: "Admin authentication")

# Test test@gmail.com (user)
IO.puts("Testing test@gmail.com (user)...")
auth_result3 = MyBelia.Accounts.authenticate_user("test@gmail.com", "TempPassword123!")
IO.inspect(auth_result3, label: "Test user authentication")

IO.puts("Authentication tests completed!")

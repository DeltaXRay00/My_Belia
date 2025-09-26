# Delete existing admin user and recreate with new password hashing
IO.puts("Deleting existing admin user...")

# Get the user
user = MyBelia.Accounts.get_user_by_email("admin@mybelia.gov.my")
if user do
  # Delete the user
  MyBelia.Repo.delete!(user)
  IO.puts("User deleted successfully")
else
  IO.puts("User not found")
end

# Create new user with Pbkdf2 password hashing
IO.puts("Creating new admin user with Pbkdf2...")
case MyBelia.Accounts.create_user(%{
  email: "admin@mybelia.gov.my",
  password: "ABC#xyz00!",
  password_confirmation: "ABC#xyz00!",
  full_name: "Administrator",
  daerah: "Kota Kinabalu",
  role: "superadmin"
}) do
  {:ok, new_user} ->
    IO.puts("New user created successfully: #{new_user.email}")
    IO.puts("Password hash: #{String.slice(new_user.password_hash, 0, 50)}...")
    
    # Test authentication
    auth_result = MyBelia.Accounts.authenticate_user("admin@mybelia.gov.my", "ABC#xyz00!")
    IO.inspect(auth_result, label: "Authentication result")
    
  {:error, changeset} ->
    IO.inspect(changeset.errors, label: "Error creating user")
end

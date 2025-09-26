# Fix all users with old password hash format
IO.puts("Checking all users with old password hash format...")

# Get all users
users = MyBelia.Repo.all(MyBelia.Accounts.User)
IO.puts("Total users: #{length(users)}")

# Check which users have old format (Bcrypt format is just a hex string)
old_format_users = Enum.filter(users, fn user ->
  # Old Bcrypt format is just a hex string without $ prefix
  !String.starts_with?(user.password_hash, "$")
end)

IO.puts("Users with old password hash format: #{length(old_format_users)}")

# Update each user with old format
Enum.each(old_format_users, fn user ->
  IO.puts("Updating user: #{user.email}")
  
  # Delete the old user
  MyBelia.Repo.delete!(user)
  
  # Create new user with Pbkdf2 password hashing
  # Use a default password for now - users will need to reset their passwords
  case MyBelia.Accounts.create_user(%{
    email: user.email,
    password: "TempPassword123!",
    password_confirmation: "TempPassword123!",
    full_name: user.full_name,
    daerah: user.daerah,
    role: user.role,
    status: user.status,
    jawatan: user.jawatan,
    unit_bahagian: user.unit_bahagian,
    ic_number: user.ic_number,
    birth_date: user.birth_date,
    birth_place: user.birth_place,
    gender: user.gender,
    phone_number: user.phone_number,
    religion: user.religion,
    race: user.race,
    residential_address: user.residential_address,
    mailing_address: user.mailing_address,
    education_level: user.education_level,
    institution: user.institution,
    field_of_study: user.field_of_study,
    course: user.course,
    graduation_date: user.graduation_date,
    avatar_url: user.avatar_url
  }) do
    {:ok, new_user} ->
      IO.puts(" Updated user: #{new_user.email}")
    {:error, changeset} ->
      IO.puts(" Error updating user #{user.email}: #{inspect(changeset.errors)}")
  end
end)

IO.puts("Password hash migration completed!")

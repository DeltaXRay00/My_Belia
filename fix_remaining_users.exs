# Fix remaining users with missing required fields
IO.puts("Fixing remaining users with missing required fields...")

# Get users that might still have old format or missing data
users = MyBelia.Repo.all(MyBelia.Accounts.User)
IO.puts("Total users after migration: #{length(users)}")

# Check for any users that still have old format
old_format_users = Enum.filter(users, fn user ->
  !String.starts_with?(user.password_hash, "$")
end)

IO.puts("Users still with old format: #{length(old_format_users)}")

# For any remaining old format users, fix them with default values
Enum.each(old_format_users, fn user ->
  IO.puts("Fixing user: #{user.email}")
  
  # Delete the old user
  MyBelia.Repo.delete!(user)
  
  # Create new user with default values for missing required fields
  case MyBelia.Accounts.create_user(%{
    email: user.email,
    password: "TempPassword123!",
    password_confirmation: "TempPassword123!",
    full_name: user.full_name || "User",
    daerah: user.daerah || "Kota Kinabalu",  # Default daerah
    role: user.role || "user",
    status: user.status || "active",
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
      IO.puts(" Fixed user: #{new_user.email}")
    {:error, changeset} ->
      IO.puts(" Error fixing user #{user.email}: #{inspect(changeset.errors)}")
  end
end)

IO.puts("User migration completed!")

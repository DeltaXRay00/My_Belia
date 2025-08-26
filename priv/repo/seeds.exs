# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     MyBelia.Repo.insert!(%MyBelia.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Create admin account
alias MyBelia.Accounts

# Check if admin already exists
case Accounts.get_user_by_email("admin@mybelia.gov.my") do
  nil ->
    # Create admin account
    {:ok, admin} = Accounts.create_user(%{
      email: "admin@mybelia.gov.my",
      password: "ABC#xyz00!",
      password_confirmation: "ABC#xyz00!",
      full_name: "Administrator",
      role: "superadmin"
    })
    IO.puts("Admin account created: #{admin.email}")

  existing_admin ->
    IO.puts("Admin account already exists: #{existing_admin.email}")
end

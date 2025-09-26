# Migration Reset Script for MyBelia
# Run this script on other devices to fix migration issues

echo "Resetting migration state..."

# Step 1: Reset the migration state
mix ecto.reset

# Step 2: Run migrations
mix ecto.migrate

# Step 3: Seed the database
mix run priv/repo/seeds.exs

echo "Migration reset complete!"
IO.puts("Checking grants table columns after migration...")
result = MyBelia.Repo.query!("SELECT column_name FROM information_schema.columns WHERE table_name = 'grants' ORDER BY ordinal_position")
IO.inspect(result.rows)

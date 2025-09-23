defmodule MyBelia.Repo.Migrations.AlignGrantApplicationsMissingColumns do
  use Ecto.Migration

  def up do
    # Organization
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS organization_name varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS registration_number varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS organization_type varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS established_date date"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS address text"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS postcode varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS district varchar"

    # Contact
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS office_phone varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS mobile_phone varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS email varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS website text"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS social_media varchar"

    # Membership/activity
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS total_members integer"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS youth_members integer"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS activity_field varchar"

    # Bank
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS bank_name varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS account_holder varchar"
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS account_number varchar"

    # Status
    execute "ALTER TABLE grant_applications ADD COLUMN IF NOT EXISTS status varchar DEFAULT 'pending'"
  end

  def down do
    :ok
  end
end

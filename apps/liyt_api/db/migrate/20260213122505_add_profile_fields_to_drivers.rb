class AddProfileFieldsToDrivers < ActiveRecord::Migration[8.1]
  def change
    add_column :drivers, :full_name, :string
    add_column :drivers, :phone, :string
    add_column :drivers, :status, :string, null: false, default: "active"
    add_column :drivers, :vehicle_type, :string
    add_column :drivers, :license_number, :string
    add_column :drivers, :verified_at, :datetime
    add_column :drivers, :rating, :decimal, precision: 3, scale: 2
    add_column :drivers, :last_latitude, :decimal, precision: 10, scale: 8
    add_column :drivers, :last_longitude, :decimal, precision: 11, scale: 8
    add_column :drivers, :last_location_at, :datetime

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE drivers
          SET phone = CONCAT('missing-', id)
          WHERE phone IS NULL
        SQL
      end
    end

    change_column_null :drivers, :phone, false
    add_index :drivers, :phone, unique: true
    add_index :drivers, :status
  end
end

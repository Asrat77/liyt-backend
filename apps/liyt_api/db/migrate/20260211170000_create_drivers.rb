class CreateDrivers < ActiveRecord::Migration[8.1]
  def change
    create_table :drivers do |t|
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps
    end

    add_index :drivers, "lower(email)", unique: true, name: "index_drivers_on_lower_email"
  end
end

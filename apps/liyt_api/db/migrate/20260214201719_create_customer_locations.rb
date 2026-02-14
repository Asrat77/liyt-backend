class CreateCustomerLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :customer_locations do |t|
      t.bigint :customer_id, null: false
      t.string :name
      t.string :address1
      t.string :address2
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country_code
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.text :instructions
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end

    add_index :customer_locations, :customer_id
    add_index :customer_locations, [ :customer_id, :is_default ]
  end
end

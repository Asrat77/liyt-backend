class CreateDeliveryStops < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_stops do |t|
      t.bigint :delivery_id, null: false
      t.string :kind, null: false
      t.integer :sequence, null: false, default: 0
      t.string :address1
      t.string :address2
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country_code
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.string :contact_name
      t.string :contact_phone
      t.text :instructions

      t.timestamps
    end

    add_index :delivery_stops, :delivery_id
    add_index :delivery_stops, [ :delivery_id, :kind ], unique: true
    add_index :delivery_stops, [ :delivery_id, :sequence ]
  end
end

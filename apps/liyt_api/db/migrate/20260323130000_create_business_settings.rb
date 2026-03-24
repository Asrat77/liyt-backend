class CreateBusinessSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :business_settings do |t|
      t.references :business, null: false, foreign_key: true, index: { unique: true }

      t.string :pickup_address1
      t.string :pickup_address2
      t.string :pickup_city
      t.string :pickup_region
      t.string :pickup_postal_code
      t.string :pickup_country_code
      t.decimal :pickup_latitude, precision: 10, scale: 8
      t.decimal :pickup_longitude, precision: 11, scale: 8
      t.string :pickup_contact_name
      t.string :pickup_contact_phone
      t.text :pickup_instructions

      t.timestamps
    end
  end
end

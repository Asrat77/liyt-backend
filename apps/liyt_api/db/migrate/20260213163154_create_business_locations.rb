class CreateBusinessLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :business_locations do |t|
      t.references :business, null: false, foreign_key: true
      t.string :name, null: false
      t.string :address1
      t.string :address2
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country_code, null: false
      t.decimal :latitude, precision: 10, scale: 8
      t.decimal :longitude, precision: 11, scale: 8
      t.text :instructions
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :business_locations, [ :business_id, :active ]
  end
end

class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.bigint :business_id
      t.bigint :driver_id
      t.bigint :customer_id
      t.string :public_id, null: false
      t.integer :status, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2
      t.text :description
      t.datetime :accepted_at
      t.datetime :picked_up_at
      t.datetime :delivered_at
      t.datetime :cancelled_at
      t.string :cancel_reason

      t.timestamps
    end

    add_index :deliveries, :public_id, unique: true
    add_index :deliveries, :business_id
    add_index :deliveries, :driver_id
    add_index :deliveries, :customer_id
    add_index :deliveries, :status
    add_index :deliveries, [ :business_id, :status, :created_at ]
  end
end

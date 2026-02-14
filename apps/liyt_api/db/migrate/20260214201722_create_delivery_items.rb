class CreateDeliveryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_items do |t|
      t.bigint :delivery_id, null: false
      t.string :name, null: false
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :delivery_items, :delivery_id
  end
end

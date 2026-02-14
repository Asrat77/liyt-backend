class CreateDeliveryEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_events do |t|
      t.bigint :delivery_id, null: false
      t.string :event_type, null: false
      t.integer :from_status
      t.integer :to_status
      t.string :actor_type
      t.bigint :actor_id
      t.text :note
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :delivery_events, :delivery_id
    add_index :delivery_events, [ :delivery_id, :occurred_at ]
    add_index :delivery_events, [ :actor_type, :actor_id ]
  end
end

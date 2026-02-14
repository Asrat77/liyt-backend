class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.string :full_name, null: false
      t.string :phone, null: false
      t.string :email
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :customers, :phone, unique: true
    add_index :customers, :email
    add_index :customers, :status
  end
end

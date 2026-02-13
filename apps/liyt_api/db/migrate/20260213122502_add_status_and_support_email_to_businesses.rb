class AddStatusAndSupportEmailToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_column :businesses, :status, :string, null: false, default: "active"
    add_column :businesses, :support_email, :string

    add_index :businesses, :status
  end
end

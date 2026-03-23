class CreateApiKeys < ActiveRecord::Migration[8.1]
  def change
    create_table :api_keys do |t|
      t.references :business, null: false, foreign_key: true, index: false
      t.references :created_by_user, null: true, foreign_key: { to_table: :users }
      t.references :revoked_by_user, null: true, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.string :prefix, null: false
      t.string :key_hash, null: false
      t.string :scopes, array: true, default: [], null: false
      t.datetime :last_used_at
      t.datetime :expires_at
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :api_keys, :prefix, unique: true
    add_index :api_keys, :key_hash, unique: true
    add_index :api_keys, [ :business_id, :revoked_at, :expires_at ], name: "index_api_keys_on_business_active_lookup"
  end
end

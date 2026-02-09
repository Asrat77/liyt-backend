class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.string :token_hash, null: false
      t.references :owner, polymorphic: true, null: false
      t.datetime :expires_at, null: false
      t.datetime :revoked_at
      t.datetime :last_used_at

      t.timestamps
    end

    add_index :refresh_tokens, [ :owner_type, :owner_id ]
    add_index :refresh_tokens, :token_hash, unique: true
  end
end

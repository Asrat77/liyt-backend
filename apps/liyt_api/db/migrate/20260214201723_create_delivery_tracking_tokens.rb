class CreateDeliveryTrackingTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_tracking_tokens do |t|
      t.bigint :delivery_id, null: false
      t.string :token_hash, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :delivery_tracking_tokens, :delivery_id
    add_index :delivery_tracking_tokens, :token_hash, unique: true
  end
end

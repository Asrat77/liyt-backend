class AddFamilyToRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :refresh_tokens, :family, :string

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE refresh_tokens
          SET family = md5(random()::text)
        SQL
      end
    end

    change_column_null :refresh_tokens, :family, false
    add_index :refresh_tokens, [ :owner_type, :owner_id, :family ]
  end
end

# This migration comes from passkeys_rails (originally 20230620012600)
class CreatePasskeysRailsPasskeys < ActiveRecord::Migration[7.0]
  def change
    create_table :passkeys_rails_passkeys do |t|
      t.string :identifier
      t.string :public_key
      t.integer :sign_count
      t.references :agent, null: false, foreign_key: { to_table: :passkeys_rails_agents }

      t.timestamps
    end
  end
end

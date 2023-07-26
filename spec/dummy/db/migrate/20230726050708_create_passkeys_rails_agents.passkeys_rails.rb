# This migration comes from passkeys_rails (originally 20230620012530)
class CreatePasskeysRailsAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :passkeys_rails_agents do |t|
      t.string :username, null: false
      t.references :authenticatable, polymorphic: true
      t.string :webauthn_identifier
      t.datetime :registered_at
      t.datetime :last_authenticated_at

      t.timestamps
    end

    # Make the authenticatable index enforce uniqueness
    remove_index :passkeys_rails_agents, %i[authenticatable_type authenticatable_id], name: 'index_passkeys_rails_agents_on_authenticatable'
    add_index :passkeys_rails_agents, %i[authenticatable_type authenticatable_id], unique: true, name: 'index_passkeys_rails_agents_on_authenticatable'
    add_index :passkeys_rails_agents, :username, unique: true
  end
end

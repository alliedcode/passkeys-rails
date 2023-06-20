class CreateMobilePassAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :mobile_pass_agents do |t|
      t.string :username, null: false
      t.references :authenticatable, polymorphic: true
      t.string :webauthn_identifier
      t.datetime :registered_at
      t.datetime :last_authenticated_at

      t.timestamps
    end

    # Make the authenticatable index enforce uniqueness
    remove_index :mobile_pass_agents, %i[authenticatable_type authenticatable_id], name: 'index_mobile_pass_agents_on_authenticatable'
    add_index :mobile_pass_agents, %i[authenticatable_type authenticatable_id], unique: true, name: 'index_mobile_pass_agents_on_authenticatable'
    add_index :mobile_pass_agents, :username, unique: true
  end
end

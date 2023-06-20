class CreateMobilePassAgents < ActiveRecord::Migration[7.0]
  def change
    create_table :mobile_pass_agents do |t|
      t.string :username
      t.references :authenticatable, polymorphic: true, null: false
      t.string :webauthn_identifier
      t.datetime :registered_at
      t.datetime :last_authenticated_at

      t.timestamps
    end

    # Make the authenticatable index enforce uniqueness
    remove_index :mobile_pass_agents, %i[authenticatable_type authenticatable_id], name: 'index_mobile_pass_agents_on_authenticatable'
    add_index :mobile_pass_agents, %i[authenticatable_type authenticatable_id], unique: true, name: 'index_mobile_pass_agents_on_authenticatable'
  end
end

class CreateMobilePassPasskeys < ActiveRecord::Migration[7.0]
  def change
    create_table :mobile_pass_passkeys do |t|
      t.string :identifier
      t.string :public_key
      t.integer :sign_count
      t.references :agent, null: false, foreign_key: { to_table: :mobile_pass_agents }

      t.timestamps
    end
  end
end
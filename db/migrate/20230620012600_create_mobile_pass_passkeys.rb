class CreateMobilePassPasskeys < ActiveRecord::Migration[7.0]
  def change
    create_table :mobile_pass_passkeys do |t|
      t.string :identifier
      t.string :public_key
      t.integer :sign_count
      t.references :mobile_pass_agent, null: false, foreign_key: true

      t.timestamps
    end
  end
end

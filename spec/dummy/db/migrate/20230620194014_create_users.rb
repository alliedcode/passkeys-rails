class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    # rubocop:disable Style/SymbolProc
    create_table :users do |t|
      t.timestamps
    end
    # rubocop:enable Style/SymbolProc
  end
end

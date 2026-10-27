class CreateAuthTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_tokens, id: :string do |t|
      t.string :resource, null: false

      t.timestamps

      t.index :resource
    end
  end
end

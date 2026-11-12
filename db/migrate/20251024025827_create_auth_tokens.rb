class CreateAuthTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :auth_tokens, id: :string do |t|
      t.string :user_id, null: false

      t.timestamps

      t.index :user_id
    end
  end
end

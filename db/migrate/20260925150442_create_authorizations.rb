class CreateAuthorizations < ActiveRecord::Migration[8.1]
  def change
    create_table :authorizations do |t|
      t.string :access_token
      t.string :refresh_token
      t.integer :expiery
      t.string :scope

      t.timestamps
    end
  end
end

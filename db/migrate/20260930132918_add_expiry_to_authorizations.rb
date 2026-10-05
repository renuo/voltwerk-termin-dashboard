class AddExpiryToAuthorizations < ActiveRecord::Migration[8.1]
  def change
    add_column :authorizations, :expiry, :integer
  end
end

class RemoveExpieryFromAuthorizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :authorizations, :expiery, :integer
  end
end

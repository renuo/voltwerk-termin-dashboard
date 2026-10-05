class AddAdminToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :admin, :integer
  end
end

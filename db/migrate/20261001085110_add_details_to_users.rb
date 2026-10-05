class AddDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :handle, :string
    add_column :users, :date_of_birth, :date
  end
end

class AddJobTitlesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :job_title, :string
  end
end

class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :firstname, :string
    add_column :users, :lasttname, :string
    add_column :users, :role, :string
  end
end

class ChangeColumnNameInUsers < ActiveRecord::Migration
  def change
    rename_column :users, :lasttname, :lastname
  end

end

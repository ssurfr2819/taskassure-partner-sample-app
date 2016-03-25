class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :users, :user_api_token, :ta_api_token
  end

end

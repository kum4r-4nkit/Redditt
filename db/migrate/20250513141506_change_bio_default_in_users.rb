class ChangeBioDefaultInUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_default :users, :bio, ""
  end
end

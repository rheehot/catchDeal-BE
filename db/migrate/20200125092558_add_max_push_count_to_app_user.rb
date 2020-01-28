class AddMaxPushCountToAppUser < ActiveRecord::Migration[5.2]
  def change
    add_column :app_users, :max_push_count, :integer, :null => false, :default => 1
  end
end

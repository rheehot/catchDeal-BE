class AddAlarmStatusToAppUser < ActiveRecord::Migration[5.2]
  def change
    add_column :app_users, :alarm_status, :boolean, :null => false, :default => true
  end
end

class AddLastTokenToAppUser < ActiveRecord::Migration[5.2]
  def change
    add_column :app_users, :last_token, :datetime
  end
end

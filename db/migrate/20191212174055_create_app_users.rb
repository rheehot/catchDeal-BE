class CreateAppUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :app_users do |t|
      t.string :app_player, null: false
      t.string :category

      t.timestamps
    end
  end
end

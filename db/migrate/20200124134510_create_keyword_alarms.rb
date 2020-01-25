class CreateKeywordAlarms < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_alarms do |t|
      t.references :app_user, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end

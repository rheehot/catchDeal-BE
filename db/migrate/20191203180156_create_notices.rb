class CreateNotices < ActiveRecord::Migration[5.2]
  def change
    create_table :notices do |t|
      t.string :user_id
      t.string :title
      t.string :category, default: "일반"
      t.text :content

      t.timestamps
    end
  end
end

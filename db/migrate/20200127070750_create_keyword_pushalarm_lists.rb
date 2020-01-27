class CreateKeywordPushalarmLists < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_pushalarm_lists do |t|
      t.belongs_to :app_user, null: false
      t.string :keyword_title, null: false
      t.belongs_to :hit_product, null: false

      t.timestamps
    end
  end
end

class CreateKeywordPushalarmLists < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_pushalarm_lists do |t|
      t.belongs_to :app_user
      t.belongs_to :hit_product

      t.timestamps
    end
  end
end

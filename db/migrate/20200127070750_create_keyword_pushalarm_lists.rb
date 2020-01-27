class CreateKeywordPushalarmLists < ActiveRecord::Migration[5.2]
  def change
    create_table :keyword_pushalarm_lists do |t|
      t.references :app_user
      t.references :hit_product

      t.timestamps
    end
  end
end

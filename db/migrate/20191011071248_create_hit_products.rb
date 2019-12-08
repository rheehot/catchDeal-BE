class CreateHitProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :hit_products do |t|
      t.string :product_id
      t.datetime :date, default: -> { 'CURRENT_TIMESTAMP' }
      t.string :title
      # t.string :brand
      t.boolean :is_sold_out
      t.string :website
      t.integer :view, default: 0
      t.integer :comment, default: 0
      t.integer :like, default: 0
      t.integer :score, default: 0
      t.string :image_url, default: 0
      t.string :url

      t.timestamps
    end
  end
end

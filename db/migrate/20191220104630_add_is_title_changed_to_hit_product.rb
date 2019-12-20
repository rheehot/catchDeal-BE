class AddIsTitleChangedToHitProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :hit_products, :is_title_changed, :boolean, default: false
  end
end

class AddDeadCheckToHitProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :hit_products, :dead_check, :boolean, default: false
  end
end

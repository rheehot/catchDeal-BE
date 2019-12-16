class AddRedirectUrlToHitProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :hit_products, :redirect_url, :string
  end
end

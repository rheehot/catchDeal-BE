class BookMark < ApplicationRecord
  validates_uniqueness_of :app_user_id, :scope => :hit_product_id
	
  belongs_to :app_user
  belongs_to :hit_product
end

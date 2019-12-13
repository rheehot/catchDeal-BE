class BookMark < ApplicationRecord
  belongs_to :app_user
  belongs_to :hit_product
end

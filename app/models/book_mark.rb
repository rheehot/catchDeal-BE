class BookMark < ApplicationRecord
  belongs_to :user
  belongs_to :hit_product
end

class AppUser < ApplicationRecord
	validates_uniqueness_of :app_player
	has_many :book_marks
    has_many :hit_products, through: :book_marks
end

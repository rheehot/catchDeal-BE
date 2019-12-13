class HitProduct < ApplicationRecord
    attr_accessor :dateAgo, :shortDate, :uid, :isSoldOut, :imageUrl, :isDeleted
    validates_uniqueness_of :url, :scope => :title
	
	has_many :book_marks
    has_many :users, through: :likes
end

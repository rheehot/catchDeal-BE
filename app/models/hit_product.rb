class HitProduct < ApplicationRecord
    attr_accessor :dateAgo, :shortDate, :uid, :isSoldOut, :imageUrl, :isDeleted
    validates_uniqueness_of :url, :scope => :title
end

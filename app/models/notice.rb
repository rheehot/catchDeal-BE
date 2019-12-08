class Notice < ApplicationRecord
    resourcify
    attr_accessor :dateAgo, :shortDate, :uid
    belongs_to :user
end
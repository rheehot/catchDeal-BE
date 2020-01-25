class KeywordAlarm < ApplicationRecord
  belongs_to :app_user
  validates_uniqueness_of :title, :scope => :app_user
end
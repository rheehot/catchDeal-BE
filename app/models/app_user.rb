class AppUser < ApplicationRecord
	validates_uniqueness_of :app_player
end

class AppUser < ApplicationRecord
	validates_uniqueness_of :app_player
	
	has_many :book_marks, dependent: :destroy
    has_many :hit_products, through: :book_marks
    
    has_many :keyword_pushalarm_lists, dependent: :destroy
    has_many :hit_products, through: :keyword_pushalarm_lists
    
    private
    
    def self.jwt_authenticate_check(header_auth_token)
        if (header_auth_token != nil)
            begin
                JWT.decode(header_auth_token, ENV["SECRET_KEY_BASE"])
                unless user_id_in_token?(header_auth_token)
                    return false
                end
            rescue
                return false
            end
            
            return user_id_in_token?(header_auth_token)[:app_user_id].to_i
        else
            return false
        end
    end
    
    protected
    
    def self.http_token(header_auth_token)
		@http_token ||= if header_auth_token.present?
			header_auth_token
		end
	end

	def self.auth_token(header_auth_token)
		@auth_token ||= JsonWebToken.decode(http_token(header_auth_token))
	end

	def self.user_id_in_token?(header_auth_token)
		http_token(header_auth_token) && auth_token(header_auth_token)
	end
end

class User < ApplicationRecord
  rolify
  after_create :assign_default_role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
	     :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null
         
  def assign_default_role
    add_role(:normal)
  end
end

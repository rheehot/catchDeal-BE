class User < ApplicationRecord
  has_many :book_marks
  has_many :hit_products, through: :likes
	
  rolify
  after_create :assign_default_role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  def assign_default_role
    add_role(:normal)
  end
end

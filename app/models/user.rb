class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  enum :role, { reviewer: "reviewer", admin: "admin" }, default: :reviewer, validate: true

  has_many :review_decisions, dependent: :restrict_with_error
  has_many :audit_events, dependent: :nullify
end

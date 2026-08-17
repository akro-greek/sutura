class Scroll < ApplicationRecord
  has_many :source_artifacts, dependent: :restrict_with_error
  has_many :passages, dependent: :restrict_with_error
  has_many :external_identifiers, as: :identifiable, dependent: :destroy

  validates :slug, :identifier, :title, :language, presence: true
  validates :slug, :identifier, uniqueness: true
end

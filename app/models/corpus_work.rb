class CorpusWork < ApplicationRecord
  has_many :corpus_passages, dependent: :restrict_with_error
  has_many :external_identifiers, as: :identifiable, dependent: :destroy

  validates :slug, :title, :language, presence: true
  validates :slug, uniqueness: true
end

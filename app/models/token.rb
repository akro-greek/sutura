class Token < ApplicationRecord
  belongs_to :reading
  has_many :lemma_candidates, dependent: :destroy

  validates :position, :surface, :normalized, presence: true
  validates :position, uniqueness: { scope: :reading_id }
end

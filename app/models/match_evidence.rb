class MatchEvidence < ApplicationRecord
  belongs_to :candidate_match
  validates :channel, inclusion: { in: %w[exact trigram lemma vector] }
  validates :channel, uniqueness: { scope: :candidate_match_id }
  validates :score, numericality: true
end

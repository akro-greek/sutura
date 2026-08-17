class CandidateMatch < ApplicationRecord
  belongs_to :source_passage, class_name: "Passage", inverse_of: :candidate_matches
  belongs_to :target_corpus_passage, class_name: "CorpusPassage", inverse_of: :candidate_matches
  has_many :match_evidences, dependent: :destroy
  has_many :review_decisions, dependent: :restrict_with_error

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected", needs_work: "needs_work" }, default: :pending, validate: true
  validates :algorithm_version, presence: true

  scope :ranked, -> { order(combined_score: :desc) }
end

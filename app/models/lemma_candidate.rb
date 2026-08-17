class LemmaCandidate < ApplicationRecord
  belongs_to :token
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: "pending", accepted: "accepted", rejected: "rejected" }, default: :pending, validate: true
  validates :lemma, :source, presence: true
end

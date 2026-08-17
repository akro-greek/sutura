class ReviewDecision < ApplicationRecord
  belongs_to :candidate_match
  belongs_to :user

  enum :verdict, { accepted: "accepted", rejected: "rejected", needs_work: "needs_work" }, validate: true
  validates :note, presence: true, if: :rejected?

  before_update :immutable!
  before_destroy :immutable!
  after_create :apply_decision!

  private

  def apply_decision!
    candidate_match.update_columns(status: verdict, updated_at: Time.current)
    AuditEvent.create!(user:, auditable: candidate_match, action: "review.#{verdict}", metadata: { decision_id: id, note: note })
  end

  def immutable!
    errors.add(:base, "Review decisions are append-only")
    throw :abort
  end
end

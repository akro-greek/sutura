class ReadingRevision < ApplicationRecord
  belongs_to :reading
  belongs_to :user, optional: true

  validates :revision_number, uniqueness: { scope: :reading_id }
  before_update :immutable!
  before_destroy :immutable!

  private

  def immutable!
    errors.add(:base, "Reading revisions are append-only")
    throw :abort
  end
end

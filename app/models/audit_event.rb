class AuditEvent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true
  before_update :immutable!
  before_destroy :immutable!

  private

  def immutable!
    errors.add(:base, "Audit events are append-only")
    throw :abort
  end
end

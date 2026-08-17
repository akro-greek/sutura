class Reading < ApplicationRecord
  belongs_to :passage
  belongs_to :source_artifact, optional: true
  has_many :reading_revisions, dependent: :restrict_with_error
  has_many :tokens, -> { order(:position) }, dependent: :destroy

  validates :diplomatic_text, :unicode_text, :search_text, :accent_folded_text, presence: true
  validates :passage_id, uniqueness: true

  before_validation :derive_search_forms
  after_create :record_initial_revision

  def revision_snapshot
    attributes.slice("source_artifact_id", "diplomatic_text", "epidoc_fragment", "unicode_text", "search_text", "accent_folded_text", "translation", "editorial_status")
  end

  def revise!(attributes, user:, note:)
    transaction do
      next_revision = current_revision_number + 1
      update!(attributes.merge(current_revision_number: next_revision))
      reading_revisions.create!(user:, revision_number: next_revision, snapshot: revision_snapshot, note:)
      AuditEvent.create!(user:, auditable: self, action: "reading.revised", metadata: { revision_number: next_revision, note: })
    end
    self
  end

  private

  def derive_search_forms
    source = unicode_text.presence || diplomatic_text
    self.unicode_text = Sutura::TextNormalizer.nfc(source)
    self.search_text = Sutura::TextNormalizer.search(unicode_text)
    self.accent_folded_text = Sutura::TextNormalizer.accent_fold(search_text)
  end

  def record_initial_revision
    reading_revisions.create!(revision_number: current_revision_number, snapshot: revision_snapshot, note: "Initial import")
  end
end

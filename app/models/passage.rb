class Passage < ApplicationRecord
  KINDS = %w[scroll column line window].freeze

  belongs_to :scroll
  belongs_to :parent, class_name: "Passage", optional: true
  has_many :children, -> { order(:position) }, class_name: "Passage", foreign_key: :parent_id, dependent: :restrict_with_error, inverse_of: :parent
  has_one :reading, dependent: :restrict_with_error
  has_many :image_regions, dependent: :destroy
  has_many :candidate_matches, foreign_key: :source_passage_id, dependent: :restrict_with_error, inverse_of: :source_passage

  validates :kind, inclusion: { in: KINDS }
  validates :label, :anchor, presence: true
  validates :anchor, uniqueness: { scope: :scroll_id }

  scope :ordered_columns, -> { where(kind: "column").order(:position) }
  scope :lines, -> { where(kind: "line").order(:position) }

  def column
    kind == "column" ? self : parent
  end
end

class ImageRegion < ApplicationRecord
  belongs_to :passage
  belongs_to :source_artifact, optional: true

  validates :shape, inclusion: { in: %w[rectangle polygon] }
  validate :valid_geometry

  private

  def valid_geometry
    required = shape == "rectangle" ? %w[x y width height] : %w[points]
    errors.add(:geometry, "is incomplete") unless required.all? { |key| geometry.key?(key) }
  end
end

class SourceArtifact < ApplicationRecord
  belongs_to :scroll, optional: true
  has_many :readings, dependent: :restrict_with_error
  has_many :image_regions, dependent: :restrict_with_error

  validates :kind, :title, :data_license, :citation, presence: true
  validates :source_url, format: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true
end

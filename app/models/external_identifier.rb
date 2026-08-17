class ExternalIdentifier < ApplicationRecord
  belongs_to :identifiable, polymorphic: true
  validates :scheme, :value, presence: true
  validates :value, uniqueness: { scope: :scheme }
end

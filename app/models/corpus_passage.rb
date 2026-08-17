class CorpusPassage < ApplicationRecord
  belongs_to :corpus_work
  has_many :candidate_matches, foreign_key: :target_corpus_passage_id, dependent: :restrict_with_error, inverse_of: :target_corpus_passage

  has_neighbors :embedding

  validates :citation, :content, :normalized_text, presence: true
  validates :citation, uniqueness: { scope: :corpus_work_id }
end

require "csv"

module Exports
  class MatchesCsv
    def initialize(scroll)
      @scroll = scroll
    end

    def call
      CSV.generate(headers: true) do |csv|
        csv << %w[source_anchor source_text target_work target_citation target_text score decision]
        accepted_matches.find_each do |match|
          csv << [ match.source_passage.anchor, match.source_passage.reading&.unicode_text, match.target_corpus_passage.corpus_work.title,
            match.target_corpus_passage.citation, match.target_corpus_passage.content, match.combined_score, match.status ]
        end
      end
    end

    private

    def accepted_matches
      CandidateMatch.accepted.includes(source_passage: :reading, target_corpus_passage: :corpus_work).where(source_passage: @scroll.passages)
    end
  end
end

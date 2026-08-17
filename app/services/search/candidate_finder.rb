module Search
  class CandidateFinder
    def initialize(query, limit: 20)
      @query = Sutura::TextNormalizer.search(query)
      @limit = limit
    end

    def call
      return [] if @query.blank?

      CorpusPassage.includes(:corpus_work)
        .where("normalized_text ILIKE ?", "%#{CorpusPassage.sanitize_sql_like(@query)}%")
        .limit(@limit)
        .map { |passage| result_for(passage) }
    end

    private

    def result_for(passage)
      matched = @query.split & passage.normalized_text.split
      { passage:, evidence: { channel: "exact", query: @query, matched_forms: matched, source: passage.corpus_work.title } }
    end
  end
end

class ShowcaseController < ApplicationController
  def review
    @match = CandidateMatch.includes(:match_evidences, source_passage: :reading, target_corpus_passage: :corpus_work)
      .find_by(id: params[:candidate_match_id]) || default_match
    raise ActiveRecord::RecordNotFound unless @match

    @source = @match.source_passage
    @target = @match.target_corpus_passage
    @scroll = @source.scroll
  end

  private

  def default_match
    CandidateMatch.includes(:match_evidences, source_passage: :reading, target_corpus_passage: :corpus_work)
      .joins(source_passage: :scroll)
      .where(scrolls: { slug: "pherc-1667" })
      .order(combined_score: :desc)
      .first
  end
end

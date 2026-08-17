module Reviewer
  class CandidateMatchesController < BaseController
    def index
      authorize CandidateMatch
      @status = params[:status].presence_in(CandidateMatch.statuses.keys)
      @candidate_matches = policy_scope(CandidateMatch).includes(:match_evidences, source_passage: :reading, target_corpus_passage: :corpus_work).ranked
      @candidate_matches = @candidate_matches.where(status: @status) if @status
    end

    def show
      @candidate_match = CandidateMatch.includes(:match_evidences, :review_decisions, source_passage: :reading, target_corpus_passage: :corpus_work).find(params[:id])
      authorize @candidate_match
      @decision = @candidate_match.review_decisions.build
    end
  end
end

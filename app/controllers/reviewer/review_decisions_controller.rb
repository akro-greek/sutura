module Reviewer
  class ReviewDecisionsController < BaseController
    def create
      candidate = CandidateMatch.find(params[:candidate_match_id])
      authorize candidate, :review?
      decision = candidate.review_decisions.build(decision_params.merge(user: current_user))
      if decision.save
        redirect_to reviewer_candidate_match_path(candidate), notice: "Decision recorded in the audit trail."
      else
        @candidate_match = candidate
        @decision = decision
        render "reviewer/candidate_matches/show", status: :unprocessable_entity
      end
    end

    private

    def decision_params
      params.require(:review_decision).permit(:verdict, :note)
    end
  end
end

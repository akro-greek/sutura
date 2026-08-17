class HomeController < ApplicationController
  def index
    @scrolls = Scroll.order(:identifier)
    @recent_runs = ImportRun.order(created_at: :desc).limit(3)
    @showcase_scroll = @scrolls.find { |scroll| scroll.metadata["showcase"] }
    @showcase_matches = CandidateMatch.joins(source_passage: :scroll)
      .where(scrolls: { id: @showcase_scroll&.id }).count
  end
end

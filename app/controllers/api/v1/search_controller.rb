module Api
  module V1
    class SearchController < BaseController
      def index
        results = Search::CandidateFinder.new(params[:q], limit: params.fetch(:limit, 20).to_i.clamp(1, 100)).call
        render json: { query: params[:q].to_s, results: results.map { |result| { id: result[:passage].id, work: result[:passage].corpus_work.title,
          citation: result[:passage].citation, text: result[:passage].content, evidence: result[:evidence] } } }
      end
    end
  end
end

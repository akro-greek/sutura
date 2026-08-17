module Api
  module V1
    class PassagesController < BaseController
      before_action :set_passage

      def show
        render json: passage_json(@passage)
      end

      def matches
        render json: { passage: passage_json(@passage), matches: @passage.candidate_matches.ranked.includes(:match_evidences, target_corpus_passage: :corpus_work).map { |match| match_json(match) } }
      end

      private

      def set_passage
        @passage = Passage.includes(:reading, :image_regions).find(params[:id])
      end

      def passage_json(passage)
        { id: passage.id, anchor: passage.anchor, label: passage.label,
         reading: passage.reading&.slice(:diplomatic_text, :unicode_text, :translation, :editorial_status),
         image_regions: passage.image_regions.map { |region| { shape: region.shape, geometry: region.geometry } } }
      end

      def match_json(match)
        { id: match.id, status: match.status, score: match.combined_score.to_f, target: { work: match.target_corpus_passage.corpus_work.title,
          citation: match.target_corpus_passage.citation, text: match.target_corpus_passage.content },
         evidence: match.match_evidences.map { |item| { channel: item.channel, score: item.score.to_f, details: item.details } } }
      end
    end
  end
end

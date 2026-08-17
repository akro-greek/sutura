module Api
  module V1
    class ScrollsController < BaseController
      def show
        scroll = Scroll.includes(:source_artifacts, passages: :reading).find_by!(slug: params[:slug])
        render json: { id: scroll.id, slug: scroll.slug, identifier: scroll.identifier, title: scroll.title, language: scroll.language,
          license: scroll.data_license, sources: scroll.source_artifacts.map { |source| { title: source.title, url: source.source_url, checksum: source.checksum, license: source.data_license, citation: source.citation } },
          passages: scroll.passages.order(:position).map { |passage| { id: passage.id, anchor: passage.anchor, kind: passage.kind, label: passage.label, parent_id: passage.parent_id, reading: passage.reading&.unicode_text } } }
      end
    end
  end
end

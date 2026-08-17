module Exports
  class JsonLd
    def initialize(scroll, base_url: nil)
      @scroll = scroll
      @base_url = base_url || "https://sutura.example"
    end

    def call
      { "@context" => { "oa" => "http://www.w3.org/ns/oa#", "dc" => "http://purl.org/dc/terms/" },
       "@id" => "#{@base_url}/texts/#{@scroll.slug}", "@type" => "dc:Text", "dc:title" => @scroll.title,
       "annotations" => accepted_annotations }.to_json
    end

    private

    def accepted_annotations
      CandidateMatch.accepted.includes(:source_passage, target_corpus_passage: :corpus_work).where(source_passage: @scroll.passages).map do |match|
        { "@type" => "oa:Annotation", "oa:hasTarget" => "#{@base_url}/texts/#{@scroll.slug}/passages/#{match.source_passage.anchor}",
         "oa:hasBody" => { "work" => match.target_corpus_passage.corpus_work.title, "citation" => match.target_corpus_passage.citation,
          "text" => match.target_corpus_passage.content }, "evidence" => match.match_evidences.map { |e| { channel: e.channel, score: e.score.to_f, details: e.details } } }
      end
    end
  end
end

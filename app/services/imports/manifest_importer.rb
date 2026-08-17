require "yaml"
require "digest"

module Imports
  class ManifestImporter
    class InvalidManifest < StandardError; end

    def initialize(path)
      @path = Pathname(path).expand_path
    end

    def call
      manifest = YAML.safe_load(@path.read, aliases: false)
      validate!(manifest)
      run = ImportRun.create!(status: :running, source: @path.to_s, version: manifest["version"].to_s,
        checksum: Digest::SHA256.file(@path).hexdigest, started_at: Time.current)

      ActiveRecord::Base.transaction do
        scroll = import_scroll(manifest.fetch("scroll"))
        artifacts = import_artifacts(scroll, manifest.fetch("artifacts", []))
        import_passages(scroll, artifacts, manifest.fetch("passages", []))
        works = import_corpus(manifest.fetch("corpus", []))
        import_matches(scroll, works, manifest.fetch("candidate_matches", []))
        run.update!(status: :completed, finished_at: Time.current, stats: statistics(scroll))
      end
      run
    rescue StandardError => error
      run&.update!(status: :failed, finished_at: Time.current, error_message: error.message)
      raise
    end

    private

    def validate!(manifest)
      raise InvalidManifest, "Manifest must be an object" unless manifest.is_a?(Hash)
      raise InvalidManifest, "version is required" if manifest["version"].blank?
      raise InvalidManifest, "scroll is required" unless manifest["scroll"].is_a?(Hash)
      %w[slug identifier title].each do |key|
        raise InvalidManifest, "scroll.#{key} is required" if manifest.dig("scroll", key).blank?
      end
    end

    def import_scroll(attributes)
      Scroll.find_or_initialize_by(slug: attributes.fetch("slug")).tap do |scroll|
        scroll.assign_attributes(attributes.slice("identifier", "title", "language", "dating", "description", "data_license", "metadata"))
        scroll.save!
      end
    end

    def import_artifacts(scroll, artifacts)
      artifacts.index_with do |attributes|
        artifact = find_artifact(scroll, attributes)
        artifact.assign_attributes(attributes.except("key", "previous_titles"))
        artifact.save!
        artifact
      end.transform_keys { |attributes| attributes.fetch("key") }
    end

    def find_artifact(scroll, attributes)
      titles = [ attributes.fetch("title"), *attributes.fetch("previous_titles", []) ]
      scroll.source_artifacts.where(kind: attributes.fetch("kind"), title: titles).first_or_initialize.tap do |artifact|
        artifact.title = attributes.fetch("title")
        artifact.kind = attributes.fetch("kind")
      end
    end

    def import_passages(scroll, artifacts, passages, parent = nil)
      passages.each do |attributes|
        passage = scroll.passages.find_or_initialize_by(anchor: attributes.fetch("anchor"))
        passage.update!(parent:, kind: attributes.fetch("kind"), label: attributes.fetch("label"), position: attributes.fetch("position", 0), metadata: attributes.fetch("metadata", {}))
        import_reading(passage, artifacts, attributes["reading"]) if attributes["reading"]
        import_region(passage, artifacts, attributes["image_region"]) if attributes["image_region"]
        import_passages(scroll, artifacts, attributes.fetch("children", []), passage)
      end
    end

    def import_reading(passage, artifacts, attributes)
      reading = passage.reading || passage.build_reading
      payload = attributes.slice("diplomatic_text", "epidoc_fragment", "unicode_text", "translation", "editorial_status")
        .merge("source_artifact" => artifacts[attributes["artifact"]])
      if reading.persisted?
        reading.revise!(payload, user: nil, note: "Manifest re-import") if payload.any? { |key, value| reading.public_send(key) != value }
      else
        reading.update!(payload)
      end
      sync_tokens(reading, attributes["tokens"])
    end

    def sync_tokens(reading, supplied_tokens)
      tokens = supplied_tokens.presence || Sutura::TextNormalizer.tokens(reading.unicode_text).map { |surface| { "surface" => surface } }
      tokens.each_with_index do |attributes, position|
        token = reading.tokens.find_or_initialize_by(position:)
        token.update!(surface: attributes.fetch("surface"), normalized: attributes["normalized"].presence || Sutura::TextNormalizer.search(attributes.fetch("surface")), morphology: attributes.fetch("morphology", {}))
        Array(attributes["lemmas"]).each do |lemma|
          token.lemma_candidates.find_or_create_by!(lemma: lemma.fetch("lemma"), source: lemma.fetch("source")) do |candidate|
            candidate.confidence = lemma["confidence"]
          end
        end
      end
      reading.tokens.where.not(position: tokens.each_index.to_a).destroy_all
    end

    def import_region(passage, artifacts, attributes)
      region = passage.image_regions.first_or_initialize
      region.update!(source_artifact: artifacts[attributes["artifact"]], shape: attributes.fetch("shape", "rectangle"), geometry: attributes.fetch("geometry"))
    end

    def import_corpus(entries)
      entries.index_with do |entry|
        work_attributes = entry.fetch("work")
        work = CorpusWork.find_or_initialize_by(slug: work_attributes.fetch("slug"))
        work.update!(work_attributes.except("slug"))
        entry.fetch("passages", []).each do |attributes|
          passage = work.corpus_passages.find_or_initialize_by(citation: attributes.fetch("citation"))
          content = attributes.fetch("content")
          passage.update!(content:, normalized_text: Sutura::TextNormalizer.search(content), lemma_sequence: attributes["lemma_sequence"], metadata: attributes.fetch("metadata", {}))
        end
        work
      end.transform_keys { |entry| entry.dig("work", "slug") }
    end

    def import_matches(scroll, works, matches)
      matches.each do |attributes|
        source = scroll.passages.find_by!(anchor: attributes.fetch("source_anchor"))
        work = works.fetch(attributes.fetch("target_work"))
        target = work.corpus_passages.find_by!(citation: attributes.fetch("target_citation"))
        match = CandidateMatch.find_or_initialize_by(source_passage: source, target_corpus_passage: target)
        match.update!(algorithm_version: attributes.fetch("algorithm_version", "manifest-v1"), combined_score: attributes.fetch("combined_score", 0), channel_ranks: attributes.fetch("channel_ranks", {}))
        attributes.fetch("evidence", []).each do |evidence|
          record = match.match_evidences.find_or_initialize_by(channel: evidence.fetch("channel"))
          record.update!(score: evidence.fetch("score"), details: evidence.fetch("details", {}))
        end
      end
    end

    def statistics(scroll)
      { scrolls: 1, passages: scroll.passages.count, readings: Reading.where(passage: scroll.passages).count,
       regions: ImageRegion.where(passage: scroll.passages).count, corpus_passages: CorpusPassage.count, candidates: CandidateMatch.count }
    end
  end
end

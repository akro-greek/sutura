module Imports
  class JsonlImporter
    def initialize(path, scroll_slug:)
      @path = Pathname(path).expand_path
      @scroll = Scroll.find_by!(slug: scroll_slug)
    end

    def call
      @path.each_line.with_index(1) do |line, line_number|
        next if line.blank?
        attributes = JSON.parse(line)
        passage = @scroll.passages.find_or_initialize_by(anchor: attributes.fetch("anchor"))
        passage.update!(kind: attributes.fetch("kind", "line"), label: attributes.fetch("label"), position: attributes.fetch("position", line_number))
        reading = passage.reading || passage.build_reading
        payload = { diplomatic_text: attributes.fetch("diplomatic_text"), unicode_text: attributes["unicode_text"].presence || attributes.fetch("diplomatic_text"),
                    epidoc_fragment: attributes["epidoc_fragment"], translation: attributes["translation"] }
        if reading.persisted?
          reading.revise!(payload, user: nil, note: "JSONL re-import") if payload.any? { |key, value| reading.public_send(key) != value }
        else
          reading.update!(payload)
        end
      rescue JSON::ParserError, KeyError => error
        raise ArgumentError, "Invalid JSONL line #{line_number}: #{error.message}"
      end
    end
  end
end

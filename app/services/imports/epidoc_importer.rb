require "digest"

module Imports
  class EpidocImporter
    NS = { "tei" => "http://www.tei-c.org/ns/1.0" }.freeze

    def initialize(path, scroll_slug:)
      @path = Pathname(path).expand_path
      @scroll = Scroll.find_by!(slug: scroll_slug)
    end

    def call
      document = Nokogiri::XML(@path.read) { |config| config.strict.nonet }
      artifact = @scroll.source_artifacts.find_or_create_by!(kind: "epidoc", title: @path.basename.to_s) do |record|
        record.data_license = "See source manifest"
        record.citation = "Imported from #{@path.basename}"
        record.checksum = Digest::SHA256.file(@path).hexdigest
      end

      document.xpath("//tei:div[@type='textpart' and (@subtype='column' or @subtype='fragment')]", NS).each_with_index do |column_node, column_index|
        column_number = column_node["n"].presence || (column_index + 1).to_s
        column = upsert_passage(nil, "column", "Column #{column_number}", "column-#{column_number}", column_index)
        column_node.xpath(".//tei:l", NS).each_with_index do |line_node, line_index|
          line_number = line_node["n"].presence || (line_index + 1).to_s
          line = upsert_passage(column, "line", "Line #{line_number}", "column-#{column_number}-line-#{line_number}", line_index)
          reading = line.reading || line.build_reading
          payload = { source_artifact: artifact, diplomatic_text: line_node.text.squish, unicode_text: line_node.text.squish,
                      epidoc_fragment: line_node.to_xml, editorial_status: "imported" }
          if reading.persisted?
            reading.revise!(payload, user: nil, note: "EpiDoc re-import") if payload.any? { |key, value| reading.public_send(key) != value }
          else
            reading.update!(payload)
          end
        end
      end
    end

    private

    def upsert_passage(parent, kind, label, anchor, position)
      @scroll.passages.find_or_initialize_by(anchor:).tap { |passage| passage.update!(parent:, kind:, label:, position:) }
    end
  end
end

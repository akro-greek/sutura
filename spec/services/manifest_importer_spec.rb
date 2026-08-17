require "rails_helper"

RSpec.describe Imports::ManifestImporter do
  subject(:importer) { described_class.new(Rails.root.join("data/manifests/pherc-1667/showcase.yml")) }

  it "is idempotent and records provenance" do
    importer.call
    counts = [ Scroll.count, Passage.count, Reading.count, ReadingRevision.count, ImageRegion.count, CorpusPassage.count, CandidateMatch.count ]

    expect { importer.call }.not_to change { [ Scroll.count, Passage.count, Reading.count, ReadingRevision.count, ImageRegion.count, CorpusPassage.count, CandidateMatch.count ] }
    expect(counts).to eq([ 1, 14, 8, 8, 8, 3, 3 ])
    expect(Reading.find_by!(passage: Passage.find_by!(anchor: "column-20-line-1-11")).source_artifact.citation).to include("Angelotti")
  end

  it "rejects manifests without a scroll" do
    path = Rails.root.join("tmp/invalid-manifest.yml")
    File.write(path, "version: 1\n")
    expect { described_class.new(path).call }.to raise_error(described_class::InvalidManifest)
  ensure
    File.delete(path) if path&.exist?
  end
end

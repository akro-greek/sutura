require "rails_helper"

RSpec.describe "append-only scholarly records" do
  before { Imports::ManifestImporter.new(Rails.root.join("data/manifests/pherc-1667/demo.yml")).call }

  it "does not update a reading revision" do
    revision = ReadingRevision.first
    expect(revision.update(note: "rewritten")).to be(false)
    expect(revision.reload.note).to eq("Initial import")
  end

  it "appends a new revision and audit event through the revision API" do
    user = User.create!(email: "editor@example.org", password: "correct-horse-battery-staple")
    reading = Reading.first

    expect { reading.revise!({ translation: "A reviewed translation" }, user:, note: "Editorial review") }
      .to change(reading.reading_revisions, :count).by(1).and change(AuditEvent, :count).by(1)
    expect(reading.reload.current_revision_number).to eq(2)
    expect(reading.reading_revisions.order(:revision_number).last.snapshot.fetch("translation")).to eq("A reviewed translation")
  end

  it "requires a reason for rejection and writes an audit event" do
    user = User.create!(email: "reviewer@example.org", password: "correct-horse-battery-staple")
    match = CandidateMatch.first

    expect(match.review_decisions.create(user:, verdict: :rejected)).not_to be_persisted
    expect { match.review_decisions.create!(user:, verdict: :rejected, note: "Lexical overlap is generic") }.to change(AuditEvent, :count).by(1)
    expect(match.reload).to be_rejected
  end
end

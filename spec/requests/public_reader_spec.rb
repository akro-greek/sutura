require "rails_helper"

RSpec.describe "public reader" do
  before { Imports::ManifestImporter.new(Rails.root.join("data/manifests/pherc-1667/showcase.yml")).call }

  it "renders a stable line permalink and provenance" do
    get "/texts/pherc-1667/columns/20/lines/1-11"
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("τῶν ἀγαθῶν")
    expect(response.body).to include("Complete virtually unwrapped writing surface")
    expect(response.headers.fetch("Content-Security-Policy")).to match(/nonce-[A-Za-z0-9+\/=]{16,}/)
  end

  it "returns passages and evidence through the read-only API" do
    passage = Passage.find_by!(anchor: "column-20-line-1-11")
    get "/api/v1/passages/#{passage.id}/matches"
    payload = response.parsed_body

    expect(response).to have_http_status(:ok)
    expect(payload.dig("passage", "anchor")).to eq("column-20-line-1-11")
    expect(payload.dig("matches", 0, "evidence").map { |item| item["channel"] }).to contain_exactly("exact", "lemma")
  end

  it "exports deterministic EpiDoc" do
    get "/exports/pherc-1667/epidoc.xml"
    expect(response).to have_http_status(:ok)
    expect(Nokogiri::XML(response.body).errors).to be_empty
    expect(response.body).to include('<TEI xmlns="http://www.tei-c.org/ns/1.0">')
  end

  it "offers a public read-only reviewer preview" do
    get "/showcase/review"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Would you connect these passages?")
    expect(response.body).to include("Nothing you click here changes scholarly data")
  end
end

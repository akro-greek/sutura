require "rails_helper"

RSpec.describe Sutura::TextNormalizer do
  it "normalizes Unicode, final sigma and accents without changing the source" do
    source = "  Φύσεως· ΛΌΓΟΣ ς "

    expect(described_class.search(source)).to eq("φύσεωσ λόγοσ σ")
    expect(described_class.accent_fold(source)).to eq("φυσεωσ λογοσ σ")
    expect(source).to eq("  Φύσεως· ΛΌΓΟΣ ς ")
  end

  it "keeps Greek words as tokens while removing editorial brackets" do
    expect(described_class.tokens("[τὸ] δὲ πᾶν")).to eq(%w[τὸ δὲ πᾶν])
  end
end

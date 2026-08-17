Imports::ManifestImporter.new(Rails.root.join("data/manifests/pherc-1667/showcase.yml")).call

# Remove records from the original synthetic interface fixture after the
# official showcase import has replaced its readings. Reviewed records are
# deliberately preserved so db:seed never destroys a human decision.
CandidateMatch.where(algorithm_version: "demo-rrf-v1").find_each do |match|
  next if match.review_decisions.exists?

  match.match_evidences.destroy_all
  match.destroy!
end

CorpusWork.where(slug: "demo-stoicorum").find_each do |work|
  next if work.corpus_passages.joins(:candidate_matches).exists?

  work.corpus_passages.destroy_all
  work.destroy!
end

if ENV["SEED_REVIEWER_EMAIL"].present? && ENV["SEED_REVIEWER_PASSWORD"].present?
  User.find_or_create_by!(email: ENV.fetch("SEED_REVIEWER_EMAIL")) do |user|
    user.password = ENV.fetch("SEED_REVIEWER_PASSWORD")
    user.name = "Demo Reviewer"
    user.role = :admin
  end
end

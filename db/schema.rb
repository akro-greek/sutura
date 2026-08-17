# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_13_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "unaccent"
  enable_extension "vector"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "audit_events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "auditable_id", null: false
    t.string "auditable_type", null: false
    t.datetime "created_at", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["auditable_type", "auditable_id"], name: "idx_audit_events_subject"
    t.index ["user_id"], name: "index_audit_events_on_user_id"
  end

  create_table "candidate_matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "algorithm_version", null: false
    t.jsonb "channel_ranks", default: {}, null: false
    t.decimal "combined_score", precision: 12, scale: 8, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.uuid "source_passage_id", null: false
    t.string "status", default: "pending", null: false
    t.uuid "target_corpus_passage_id", null: false
    t.datetime "updated_at", null: false
    t.index ["source_passage_id", "target_corpus_passage_id"], name: "idx_candidate_matches_pair", unique: true
    t.index ["source_passage_id"], name: "index_candidate_matches_on_source_passage_id"
    t.index ["status", "combined_score"], name: "index_candidate_matches_on_status_and_combined_score"
    t.index ["target_corpus_passage_id"], name: "index_candidate_matches_on_target_corpus_passage_id"
  end

  create_table "corpus_passages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "citation", null: false
    t.text "content", null: false
    t.uuid "corpus_work_id", null: false
    t.datetime "created_at", null: false
    t.vector "embedding", limit: 384
    t.text "lemma_sequence"
    t.jsonb "metadata", default: {}, null: false
    t.text "normalized_text", null: false
    t.datetime "updated_at", null: false
    t.index ["corpus_work_id", "citation"], name: "index_corpus_passages_on_corpus_work_id_and_citation", unique: true
    t.index ["corpus_work_id"], name: "index_corpus_passages_on_corpus_work_id"
    t.index ["embedding"], name: "index_corpus_passages_on_embedding", opclass: :vector_cosine_ops, using: :hnsw
    t.index ["normalized_text"], name: "index_corpus_passages_on_normalized_text", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "corpus_works", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "author"
    t.datetime "created_at", null: false
    t.string "language", default: "grc", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_corpus_works_on_slug", unique: true
  end

  create_table "export_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "checksum"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "finished_at"
    t.string "source"
    t.datetime "started_at"
    t.jsonb "stats", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "external_identifiers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "identifiable_id", null: false
    t.string "identifiable_type", null: false
    t.string "scheme", null: false
    t.datetime "updated_at", null: false
    t.string "uri"
    t.string "value", null: false
    t.index ["identifiable_type", "identifiable_id"], name: "idx_external_identifiers_owner"
    t.index ["scheme", "value"], name: "index_external_identifiers_on_scheme_and_value", unique: true
  end

  create_table "image_regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "geometry", default: {}, null: false
    t.uuid "passage_id", null: false
    t.string "shape", default: "rectangle", null: false
    t.uuid "source_artifact_id"
    t.datetime "updated_at", null: false
    t.index ["passage_id"], name: "index_image_regions_on_passage_id"
    t.index ["source_artifact_id"], name: "index_image_regions_on_source_artifact_id"
  end

  create_table "import_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "checksum"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "finished_at"
    t.string "source"
    t.datetime "started_at"
    t.jsonb "stats", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "index_runs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "checksum"
    t.datetime "created_at", null: false
    t.text "error_message"
    t.datetime "finished_at"
    t.string "source"
    t.datetime "started_at"
    t.jsonb "stats", default: {}, null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "version"
  end

  create_table "lemma_candidates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "confidence", precision: 5, scale: 4
    t.datetime "created_at", null: false
    t.string "lemma", null: false
    t.datetime "reviewed_at"
    t.uuid "reviewed_by_id"
    t.string "source", null: false
    t.string "status", default: "pending", null: false
    t.uuid "token_id", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_by_id"], name: "index_lemma_candidates_on_reviewed_by_id"
    t.index ["token_id", "lemma", "source"], name: "index_lemma_candidates_on_token_id_and_lemma_and_source", unique: true
    t.index ["token_id"], name: "index_lemma_candidates_on_token_id"
  end

  create_table "match_evidences", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_match_id", null: false
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.jsonb "details", default: {}, null: false
    t.decimal "score", precision: 12, scale: 8, null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_match_id", "channel"], name: "index_match_evidences_on_candidate_match_id_and_channel", unique: true
    t.index ["candidate_match_id"], name: "index_match_evidences_on_candidate_match_id"
  end

  create_table "passages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "anchor", null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.string "label", null: false
    t.jsonb "metadata", default: {}, null: false
    t.uuid "parent_id"
    t.integer "position", default: 0, null: false
    t.uuid "scroll_id", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "position"], name: "index_passages_on_parent_id_and_position"
    t.index ["parent_id"], name: "index_passages_on_parent_id"
    t.index ["scroll_id", "anchor"], name: "index_passages_on_scroll_id_and_anchor", unique: true
    t.index ["scroll_id"], name: "index_passages_on_scroll_id"
  end

  create_table "reading_revisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "note"
    t.uuid "reading_id", null: false
    t.integer "revision_number", null: false
    t.jsonb "snapshot", default: {}, null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["reading_id", "revision_number"], name: "index_reading_revisions_on_reading_id_and_revision_number", unique: true
    t.index ["reading_id"], name: "index_reading_revisions_on_reading_id"
    t.index ["user_id"], name: "index_reading_revisions_on_user_id"
  end

  create_table "readings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "accent_folded_text", null: false
    t.datetime "created_at", null: false
    t.integer "current_revision_number", default: 1, null: false
    t.text "diplomatic_text", null: false
    t.string "editorial_status", default: "draft", null: false
    t.text "epidoc_fragment"
    t.uuid "passage_id", null: false
    t.text "search_text", null: false
    t.uuid "source_artifact_id"
    t.text "translation"
    t.text "unicode_text", null: false
    t.datetime "updated_at", null: false
    t.index ["accent_folded_text"], name: "index_readings_on_accent_folded_text", opclass: :gin_trgm_ops, using: :gin
    t.index ["passage_id"], name: "index_readings_on_passage_id", unique: true
    t.index ["source_artifact_id"], name: "index_readings_on_source_artifact_id"
  end

  create_table "review_decisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "candidate_match_id", null: false
    t.datetime "created_at", null: false
    t.text "note"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.string "verdict", null: false
    t.index ["candidate_match_id"], name: "index_review_decisions_on_candidate_match_id"
    t.index ["user_id"], name: "index_review_decisions_on_user_id"
  end

  create_table "scrolls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "data_license"
    t.string "dating"
    t.text "description"
    t.string "identifier", null: false
    t.string "language", default: "grc", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "slug", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_scrolls_on_identifier", unique: true
    t.index ["slug"], name: "index_scrolls_on_slug", unique: true
  end

  create_table "source_artifacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accessed_at"
    t.string "checksum"
    t.text "citation", null: false
    t.datetime "created_at", null: false
    t.string "data_license", null: false
    t.string "kind", null: false
    t.string "local_path"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "scroll_id"
    t.string "source_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["checksum"], name: "index_source_artifacts_on_checksum"
    t.index ["scroll_id"], name: "index_source_artifacts_on_scroll_id"
  end

  create_table "tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "editorial_status", default: "visible", null: false
    t.jsonb "morphology", default: {}, null: false
    t.string "normalized", null: false
    t.integer "position", null: false
    t.uuid "reading_id", null: false
    t.string "surface", null: false
    t.datetime "updated_at", null: false
    t.index ["normalized"], name: "index_tokens_on_normalized"
    t.index ["reading_id", "position"], name: "index_tokens_on_reading_id_and_position", unique: true
    t.index ["reading_id"], name: "index_tokens_on_reading_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "invitation_accepted_at"
    t.datetime "invitation_created_at"
    t.integer "invitation_limit"
    t.datetime "invitation_sent_at"
    t.string "invitation_token"
    t.integer "invitations_count", default: 0
    t.uuid "invited_by_id"
    t.string "invited_by_type"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "reviewer", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "audit_events", "users"
  add_foreign_key "candidate_matches", "corpus_passages", column: "target_corpus_passage_id"
  add_foreign_key "candidate_matches", "passages", column: "source_passage_id"
  add_foreign_key "corpus_passages", "corpus_works"
  add_foreign_key "image_regions", "passages"
  add_foreign_key "image_regions", "source_artifacts"
  add_foreign_key "lemma_candidates", "tokens"
  add_foreign_key "lemma_candidates", "users", column: "reviewed_by_id"
  add_foreign_key "match_evidences", "candidate_matches"
  add_foreign_key "passages", "passages", column: "parent_id"
  add_foreign_key "passages", "scrolls"
  add_foreign_key "reading_revisions", "readings"
  add_foreign_key "reading_revisions", "users"
  add_foreign_key "readings", "passages"
  add_foreign_key "readings", "source_artifacts"
  add_foreign_key "review_decisions", "candidate_matches"
  add_foreign_key "review_decisions", "users"
  add_foreign_key "source_artifacts", "scrolls"
  add_foreign_key "tokens", "readings"
end

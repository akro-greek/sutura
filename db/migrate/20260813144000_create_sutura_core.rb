class CreateSuturaCore < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    enable_extension "unaccent" unless extension_enabled?("unaccent")
    enable_extension "vector" unless extension_enabled?("vector")

    create_table :scrolls, id: :uuid do |t|
      t.string :slug, null: false
      t.string :identifier, null: false
      t.string :title, null: false
      t.string :language, null: false, default: "grc"
      t.string :dating
      t.text :description
      t.string :data_license
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :scrolls, :slug, unique: true
    add_index :scrolls, :identifier, unique: true

    create_table :source_artifacts, id: :uuid do |t|
      t.references :scroll, type: :uuid, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false
      t.string :source_url
      t.string :checksum
      t.string :data_license, null: false
      t.text :citation, null: false
      t.string :local_path
      t.jsonb :metadata, null: false, default: {}
      t.datetime :accessed_at
      t.timestamps
    end
    add_index :source_artifacts, :checksum

    create_table :external_identifiers, id: :uuid do |t|
      t.string :identifiable_type, null: false
      t.uuid :identifiable_id, null: false
      t.string :scheme, null: false
      t.string :value, null: false
      t.string :uri
      t.timestamps
    end
    add_index :external_identifiers, %i[identifiable_type identifiable_id], name: "idx_external_identifiers_owner"
    add_index :external_identifiers, %i[scheme value], unique: true

    create_table :passages, id: :uuid do |t|
      t.references :scroll, null: false, type: :uuid, foreign_key: true
      t.references :parent, type: :uuid, foreign_key: { to_table: :passages }
      t.string :kind, null: false
      t.string :label, null: false
      t.string :anchor, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :passages, %i[scroll_id anchor], unique: true
    add_index :passages, %i[parent_id position]

    create_table :readings, id: :uuid do |t|
      t.references :passage, null: false, type: :uuid, foreign_key: true, index: { unique: true }
      t.references :source_artifact, type: :uuid, foreign_key: true
      t.text :diplomatic_text, null: false
      t.text :epidoc_fragment
      t.text :unicode_text, null: false
      t.text :search_text, null: false
      t.text :accent_folded_text, null: false
      t.text :translation
      t.string :editorial_status, null: false, default: "draft"
      t.integer :current_revision_number, null: false, default: 1
      t.timestamps
    end
    add_index :readings, :accent_folded_text, using: :gin, opclass: :gin_trgm_ops

    create_table :reading_revisions, id: :uuid do |t|
      t.references :reading, null: false, type: :uuid, foreign_key: true
      t.references :user, type: :uuid, foreign_key: true
      t.integer :revision_number, null: false
      t.jsonb :snapshot, null: false, default: {}
      t.text :note
      t.timestamps
    end
    add_index :reading_revisions, %i[reading_id revision_number], unique: true

    create_table :image_regions, id: :uuid do |t|
      t.references :passage, null: false, type: :uuid, foreign_key: true
      t.references :source_artifact, type: :uuid, foreign_key: true
      t.string :shape, null: false, default: "rectangle"
      t.jsonb :geometry, null: false, default: {}
      t.timestamps
    end

    create_table :tokens, id: :uuid do |t|
      t.references :reading, null: false, type: :uuid, foreign_key: true
      t.integer :position, null: false
      t.string :surface, null: false
      t.string :normalized, null: false
      t.string :editorial_status, null: false, default: "visible"
      t.jsonb :morphology, null: false, default: {}
      t.timestamps
    end
    add_index :tokens, %i[reading_id position], unique: true
    add_index :tokens, :normalized

    create_table :lemma_candidates, id: :uuid do |t|
      t.references :token, null: false, type: :uuid, foreign_key: true
      t.string :lemma, null: false
      t.string :source, null: false
      t.decimal :confidence, precision: 5, scale: 4
      t.string :status, null: false, default: "pending"
      t.references :reviewed_by, type: :uuid, foreign_key: { to_table: :users }
      t.datetime :reviewed_at
      t.timestamps
    end
    add_index :lemma_candidates, %i[token_id lemma source], unique: true

    create_table :corpus_works, id: :uuid do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.string :author
      t.string :language, null: false, default: "grc"
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :corpus_works, :slug, unique: true

    create_table :corpus_passages, id: :uuid do |t|
      t.references :corpus_work, null: false, type: :uuid, foreign_key: true
      t.string :citation, null: false
      t.text :content, null: false
      t.text :normalized_text, null: false
      t.text :lemma_sequence
      t.vector :embedding, limit: 384
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :corpus_passages, %i[corpus_work_id citation], unique: true
    add_index :corpus_passages, :normalized_text, using: :gin, opclass: :gin_trgm_ops

    create_table :candidate_matches, id: :uuid do |t|
      t.references :source_passage, null: false, type: :uuid, foreign_key: { to_table: :passages }
      t.references :target_corpus_passage, null: false, type: :uuid, foreign_key: { to_table: :corpus_passages }
      t.string :status, null: false, default: "pending"
      t.string :algorithm_version, null: false
      t.jsonb :channel_ranks, null: false, default: {}
      t.decimal :combined_score, precision: 12, scale: 8, null: false, default: 0
      t.timestamps
    end
    add_index :candidate_matches, %i[source_passage_id target_corpus_passage_id], unique: true, name: "idx_candidate_matches_pair"
    add_index :candidate_matches, %i[status combined_score]

    create_table :match_evidences, id: :uuid do |t|
      t.references :candidate_match, null: false, type: :uuid, foreign_key: true
      t.string :channel, null: false
      t.decimal :score, precision: 12, scale: 8, null: false
      t.jsonb :details, null: false, default: {}
      t.timestamps
    end
    add_index :match_evidences, %i[candidate_match_id channel], unique: true

    create_table :review_decisions, id: :uuid do |t|
      t.references :candidate_match, null: false, type: :uuid, foreign_key: true
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.string :verdict, null: false
      t.text :note
      t.timestamps
    end

    %i[import_runs index_runs export_runs].each do |table_name|
      create_table table_name, id: :uuid do |t|
        t.string :status, null: false, default: "pending"
        t.string :source
        t.string :version
        t.string :checksum
        t.jsonb :stats, null: false, default: {}
        t.text :error_message
        t.datetime :started_at
        t.datetime :finished_at
        t.timestamps
      end
    end

    create_table :audit_events, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.string :auditable_type, null: false
      t.uuid :auditable_id, null: false
      t.string :action, null: false
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end
    add_index :audit_events, %i[auditable_type auditable_id], name: "idx_audit_events_subject"
  end
end

class EmbedCorpusPassageJob < ApplicationJob
  queue_as :indexing

  def perform(corpus_passage_id)
    passage = CorpusPassage.find(corpus_passage_id)
    model = Informers.pipeline("embedding", ENV.fetch("SUTURA_EMBEDDING_MODEL", "sentence-transformers/all-MiniLM-L6-v2"))
    passage.update!(embedding: model.call(passage.normalized_text))
  end
end

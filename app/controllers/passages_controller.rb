class PassagesController < ApplicationController
  before_action :set_context

  def show
    @matches = matches_for_selected_line
    render "texts/reader"
  end

  def matches
    @matches = matches_for_selected_line
  end

  private

  def set_context
    @scroll = Scroll.find_by!(slug: params[:slug])
    @columns = @scroll.passages.ordered_columns
    @column = @columns.find { |column| [ "column-#{params[:column]}", params[:column], params[:column].to_s.parameterize ].include?(column.anchor) || column.label.parameterize == params[:column] }
    raise ActiveRecord::RecordNotFound unless @column

    @lines = @column.children.lines
    @selected_line = @lines.find { |line| [ "#{@column.anchor}-line-#{params[:line]}", params[:line] ].include?(line.anchor) || line.label.parameterize == params[:line] }
    raise ActiveRecord::RecordNotFound unless @selected_line
  end

  def matches_for_selected_line
    @selected_line.candidate_matches.ranked.includes(:match_evidences, target_corpus_passage: :corpus_work)
  end
end

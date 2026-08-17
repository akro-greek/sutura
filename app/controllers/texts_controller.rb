class TextsController < ApplicationController
  before_action :set_scroll

  def show
    @columns = @scroll.passages.ordered_columns
    @column = @columns.first
    @lines = @column&.children&.lines || Passage.none
    @selected_line = @lines.first
    render :reader
  end

  def column
    @columns = @scroll.passages.ordered_columns
    @column = find_column(params[:column])
    @lines = @column.children.lines
    @selected_line = @lines.first
    render :reader
  end

  private

  def set_scroll
    @scroll = Scroll.find_by!(slug: params[:slug])
  end

  def find_column(value)
    @scroll.passages.ordered_columns.find { |column| [ column.anchor, column.position.to_s, column.label.parameterize ].include?(value) } ||
      @scroll.passages.ordered_columns.find_by!(anchor: "column-#{value}")
  end
end

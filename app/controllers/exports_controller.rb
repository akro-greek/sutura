class ExportsController < ApplicationController
  before_action :set_scroll

  def epidoc
    send_data Exports::Epidoc.new(@scroll).call, filename: "#{@scroll.slug}.xml", type: "application/xml", disposition: :inline
  end

  def graph
    send_data Exports::JsonLd.new(@scroll, base_url: request.base_url).call, filename: "#{@scroll.slug}.jsonld", type: "application/ld+json", disposition: :inline
  end

  def matches
    send_data Exports::MatchesCsv.new(@scroll).call, filename: "#{@scroll.slug}-matches.csv", type: "text/csv", disposition: :inline
  end

  private

  def set_scroll
    @scroll = Scroll.find_by!(slug: params[:slug])
  end
end

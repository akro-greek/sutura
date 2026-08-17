module Search
  class HybridRanker
    K = 60.0

    def self.call(channels)
      scores = Hash.new(0.0)
      channels.each_value do |records|
        records.each_with_index { |record, index| scores[record] += 1.0 / (K + index + 1) }
      end
      scores.sort_by { |_record, score| -score }.to_h
    end
  end
end

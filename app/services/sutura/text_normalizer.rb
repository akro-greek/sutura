module Sutura
  class TextNormalizer
    EDITORIAL_PUNCTUATION = /[\[\]⟦⟧⟨⟩{}()·.,;:!?—–]/

    class << self
      def nfc(value)
        value.to_s.unicode_normalize(:nfc)
      end

      def search(value)
        nfc(value).downcase.tr("ς", "σ").gsub(EDITORIAL_PUNCTUATION, " ").gsub(/\s+/, " ").strip
      end

      def accent_fold(value)
        search(value).unicode_normalize(:nfd).gsub(/\p{Mn}/, "").unicode_normalize(:nfc)
      end

      def tokens(value)
        search(value).scan(/[\p{L}\p{M}]+/)
      end
    end
  end
end

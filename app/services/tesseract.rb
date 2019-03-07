class Tesseract
  class << self
    def languages
      language_output.split("\n")[1..-1].map(&:to_sym) \
                     .each_with_object({}) do |lang, hsh|
        hsh[lang] = label(lang)
      end.with_indifferent_access
    end

    def try_languages(langs)
      Array.wrap(langs).select { |lang| languages[lang].present? }.join('+')
    end

    private

      def label(lang)
        if iso_result(lang)
          iso_result(lang).english_name
        else
          I18n.t("simple_form.options.defaults.ocr_language.#{lang}",
                 default: lang.to_s)
        end
      end

      def iso_result(lang)
        # rubocop:disable Rails/DynamicFindBy
        ISO_639.find_by_code(lang.to_s)
        # rubocop:enable Rails/DynamicFindBy
      end

      def language_output
        @language_output ||= `tesseract --list-langs 2>&1`
      end
  end
end
